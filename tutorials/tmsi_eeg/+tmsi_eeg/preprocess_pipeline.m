function myPipe = preprocess_pipeline(varargin)
% PREPROCESS_PIPELINE - A very basic preprocessing pipeline

import meegpipe.node.*;

nodeList = {};

%% Node 1: data import
load('sensors_grunberg');

myImporter = physioset.import.poly5('Sensors', mySensors);
myNode = physioset_import.new('Importer', myImporter);
nodeList = [nodeList {myNode}];

%% Node 2: Select the relevant subset of data
mySelector = pset.selector.sensor_idx(5:32);
myNode = subset.new('DataSelector', mySelector);
nodeList = [nodeList {myNode}];

%% Node 3: Add events to mark the relevant data epochs
myEvGen = tmsi_eeg.grunberg_generator.default;
myNode = meegpipe.node.ev_gen.new(...
    'EventGenerator', myEvGen, ...
    'DataSelector',   pset.selector.all_data);
nodeList = [nodeList {myNode}];

%% Node 4: Preliminary bad epoch rejection
% To minimize filteringa artifacts in the following filter nodes
myCrit = bad_epochs.criterion.stat.new(...
    'Max',              @(stats) median(stats)+2*mad(stats), ...
    'EpochStat',        @(x) max(x));
myNode = bad_epochs.sliding_window(5, 5, 'Criterion', myCrit);
nodeList = [nodeList {myNode}];


%% Node 5: reject bad channels using variance
myCrit = bad_channels.criterion.var.new(...
    'Max', @(x) median(x) + 2*mad(x), 'MaxCard', 5);
myNode = bad_channels.new('Criterion', myCrit);
nodeList = [nodeList {myNode}];

%% Node 6: reject bad channels using cross correlation
myCrit = bad_channels.criterion.xcorr.new(...
    'Min', 0.2, 'MaxCard', 5);
myNode = bad_channels.new('Criterion', myCrit);
nodeList = [nodeList {myNode}];

%% Node 7: center
% This is not really required but will make the report of the subsequent
% filtering node more meaningful (since filter input and output will have a
% more similar dynamic range). 
nodeList = [nodeList {center.new}];

%% Node 8: High pass filtering
myFilter = @(sr) filter.hpfilt('fc', 3/(sr/2));
myNode = filter.new('Filter', myFilter);
nodeList = [nodeList {myNode}];

%% Node 11: Low pass filtering
myFilter = @(sr) filter.lpfilt('fc', 43/(sr/2));
myNode = filter.new('Filter', myFilter);
nodeList = [nodeList {myNode}];

%% Node 10: downsampling
myNode = resample.new('OutputRate', 250);
nodeList = [nodeList {myNode}];

%% Node 12: reject bad epochs (again)
% Trying to get rid off large filtering artifacts
myCrit = bad_epochs.criterion.stat.new(...
    'Max',              @(stats) median(stats)+2*mad(stats), ...
    'EpochStat',        @(x) max(x));
myNode = bad_epochs.sliding_window(1, 5, ...
    'Criterion',      myCrit, ...
    'DataSelector',   pset.selector.all_data);
nodeList = [nodeList {myNode}];

%% Node 13: reject ECG components
myNode = bss.ecg('RetainedVar', 99.99);
nodeList = [nodeList {myNode}];

%% Node 14: reject EOG components
myFeat1 = spt.feature.psd_ratio.eog;
myFeat2 = spt.feature.bp_var;
myCrit = spt.criterion.threshold('Feature', {myFeat1, myFeat2}, ...
    'Max',      {15 15}, ...
    'MinCard',  2, ...
    'MaxCard',  6);
myNode = bss.eog(...
    'RetainedVar',  99.99, ...
    'Criterion',    myCrit, ...
    'IOReport',     report.plotter.io, ...
    'Filter',       []);
nodeList = [nodeList {myNode}];


%% Node 9: EMG
% I think is best to remove the EMG noise before downsampling (next node)
myNode = bss.emg('CorrectionTh', 50, 'IOReport',     report.plotter.io);
nodeList = [nodeList {myNode}];


%% Create the pipeline
myPipe = pipeline.new(...
    'Name',             'preprocess-pipeline', ...
    'NodeList',         nodeList, ...
    'Save',             true, ...
    varargin{:});

end