function myPipe = cleaning_pipeline(varargin)

import meegpipe.*;

import pset.selector.sensor_class;
import pset.selector.cascade;
import pset.selector.good_data;

USE_OGE = true;
DO_REPORT = true;
QUEUE = 'short.q@somerenserver.herseninstituut.knaw.nl';

nodeList = {};

%% Import
myImporter = physioset.import.physioset;
myNode = node.physioset_import.new('Importer', myImporter);
nodeList = [nodeList {myNode}];

%% copy data
nodeList = [nodeList {node.copy.new}];

%% high-pass filter
myNode = node.filter.new(...
    'Filter', @(sr) filter.hpfilt('Fc', 1/(sr/2)));
nodeList = [nodeList {myNode}];

%% low-pass filter
myNode = node.filter.new(...
    'Filter', @(sr) filter.hpfilt('Fc', 70/(sr/2)));
nodeList = [nodeList {myNode}];

%% bad channel rejection (using variance)
minVal = @(x) median(x) - 40;
maxVal = @(x) median(x) + 15;
myCrit = node.bad_channels.criterion.var.new('Min', minVal, 'Max', maxVal);
myNode = bad_channels.new('Criterion', myCrit);
nodeList = [nodeList {myNode}];

%% bad channel rejection (using xcorr)
myCrit = node.bad_channels.criterion.xcorr.new('Min', 0.15, 'MaxCard', 4);
myNode = node.bad_channels.new('Criterion', myCrit);
nodeList = [nodeList {myNode}];

%% bad epochs
myNode = node.bad_epochs.sliding_window(1, 2, ...
    'Max',          @(x) median(x) + 3*mad(x));
nodeList = [nodeList {myNode}];

%% Node: Downsample
myNode = node.resample.new('OutputRate', 250);
nodeList = [nodeList {myNode}];

%% Node: remove PWL noise
myNode = aar.pwl.new('IOReport', report.plotter.io);
nodeList = [nodeList {myNode}];

%% Node: remove MUX noise

% MUX noise seems to appear only very rarely. Seems the purpose of this
% node is to reject only that type of noise, we set the Max threshold to a
% very large value to try to remove only true MUX-related components.
mySel = cascade(sensor_class('Class', 'EEG'), good_data);
myFeat = spt.feature.psd_ratio(...
    'TargetBand',   [12 16;49 51;17 19], ...
    'RefBand',      [7 10]);

myCrit = spt.criterion.threshold(...
    'Feature',  myFeat, ...
    'Max',      @(x) min(median(x) + 10*mad(x), 100), ...
    'MaxCard',  2);

myPCA  = spt.pca(...
    'RetainedVar',99.75, ...
    'MaxCard',    15, ...
    'MinCard',    35);
myNode = node.bss.new(...
    'DataSelector',     mySel, ...
    'Criterion',        myCrit, ...
    'PCA',              myPCA, ...
    'BSS',              spt.bss.efica, ...
    'Name',             'mux-noise', ...
    'IOReport',         report.plotter.io);

nodeList = [nodeList {myNode}];

%% Node: Reject EOG components using their topography
myNode = aar.eog.topo_egi256_hcgsn1(...
    'RetainedVar',  99.85, ...
    'MinCard',      2, ...
    'MaxCard',      5, ...
    'IOReport',     report.plotter.io);
nodeList = [nodeList {myNode}];

%% Node: ECG
myNode = aar.ecg.new;
nodeList = [nodeList {myNode}];

%% low-pass filter
myNode = node.filter.new(...
    'Filter', @(sr) filter.hpfilt('Fc', 42/(sr/2)));
nodeList = [nodeList {myNode}];

%% supervised BSS
myNode = aar.bss_supervised;
nodeList = [nodeList {myNode}];

%% Pipeline
myPipe = node.pipeline.new(...
    'NodeList',         nodeList, ...
    'Save',             true, ...
    'Parallelize',      USE_OGE, ...
    'GenerateReport',   DO_REPORT, ...
    'Name',             'cleaning_pipe', ...
    'Queue',            QUEUE, ...
    varargin{:} ...
    );

