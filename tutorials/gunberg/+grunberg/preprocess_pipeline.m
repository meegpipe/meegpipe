function myPipe = preprocess_pipeline(varargin)
% PREPROCESS_PIPELINE - A very basic preprocessing pipeline

import meegpipe.node.*;
import mperl.file.spec.catfile;

nodeList = {};

%% Node 1: data import
load(catfile(grunberg.root_path, 'sensors_grunberg'));

myImporter = physioset.import.poly5('Sensors', mySensors);
myNode = physioset_import.new('Importer', myImporter);
nodeList = [nodeList {myNode}];

%% Node 2: Select the relevant subset of data
mySelector = pset.selector.sensor_idx(5:32);
myNode = subset.new('DataSelector', mySelector);
nodeList = [nodeList {myNode}];

%% Node 3: Add events to mark the relevant data epochs
myEvGen = grunberg.grunberg_generator.default;
myNode = meegpipe.node.ev_gen.new(...
    'EventGenerator', myEvGen, ...
    'DataSelector',   pset.selector.all_data);
nodeList = [nodeList {myNode}];

%% Node 4: Preliminary bad epoch rejection
% To minimize filtering artifacts in the following filter nodes
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

%% Node 8: Band pass filtering
myFilter = @(sr) filter.eeglab_fir('Fp', [0.5 43]/(sr/2));
myNode = filter.new('Filter', myFilter);
nodeList = [nodeList {myNode}];

% %% Node: remove large signal fluctuations using a LASIP filter
% 
% % Setting the "right" parameters of the filter involves quite a bit of
% % trial and error. These values seemed OK to me but we should check
% % carefully the reports to be sure that nothing went terribly wrong. In
% % particular you should ensure that the LASIP filter is not removing
% % valuable signal. It is OK if some residual noise is left after the LASIP
% % filter so better to be conservative here.
% myScales =  [20, 29, 42, 60, 87, 100, 126, 140, 182, 215, 264, 310, 382];
% 
% myFilter = filter.lasip(...
%     'Decimation',       12, ...
%     'GetNoise',         true, ... % Retrieve the filtering residuals
%     'Gamma',            15, ...
%     'Scales',           myScales, ...
%     'WindowType',       {'Gaussian'}, ...
%     'VarTh',            0.1);
% 
% % This object especifies which subset of data should be processed by the
% % node. In this case we want to process only the EEG data, and ignore any
% % other modalities.
% mySel = pset.selector.sensor_class('Class', 'EEG');
% 
% myNode = filter.new(...
%     'Filter',           myFilter, ...
%     'Name',             'lasip', ...
%     'DataSelector',     mySel, ...
%     'ShowDiffReport',   true ...
%     );
% 
% nodeList = [nodeList {myNode}];
% 
% %% Node 9: Low pass filtering
% myFilter = @(sr) filter.lpfilt('fc', 42/(sr/2));
% myNode = filter.new('Filter', myFilter);
% nodeList = [nodeList {myNode}];

%% Node 10: downsampling
myNode = resample.new('OutputRate', 250);
nodeList = [nodeList {myNode}];

%% Create the pipeline
myPipe = pipeline.new(...
    'Name',             'preprocess-pipeline', ...
    'NodeList',         nodeList, ...
    'Save',             true, ...
    varargin{:});

end