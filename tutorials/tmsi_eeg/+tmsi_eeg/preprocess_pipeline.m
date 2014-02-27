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

%% Node 8: High pass filtering
myFilter = @(sr) filter.hpfilt('fc', 3/(sr/2));
myNode = filter.new('Filter', myFilter);
nodeList = [nodeList {myNode}];

%% Node 9: Low pass filtering
myFilter = @(sr) filter.lpfilt('fc', 42/(sr/2));
myNode = filter.new('Filter', myFilter);
nodeList = [nodeList {myNode}];

%% Node 10: downsampling
myNode = resample.new('OutputRate', 250);
nodeList = [nodeList {myNode}];

%% Node: remove PWL noise
myNode = aar.pwl.new('IOReport', report.plotter.io);
nodeList = [nodeList {myNode}];

%% Node: remove ECG components
myNode = aar.ecg.new('IOReport', report.plotter.io);
nodeList = [nodeList {myNode}];

%% Node: remove EOG components
myNode = aar.eog.new('IOReport', report.plotter.io);
nodeList = [nodeList {myNode}];

%% Node 11: supervised BSS
myNode = aar.bss_supervised;
nodeList = [nodeList {myNode}];

%% Node 9: EMG
myNode = bss.emg(...
    'CorrectionTh',     80, ...
    'ShowDiffReport',   true, ...
    'IOReport',         report.plotter.io);
nodeList = [nodeList {myNode}];

%% Create the pipeline
myPipe = pipeline.new(...
    'Name',             'preprocess-pipeline', ...
    'NodeList',         nodeList, ...
    'Save',             true, ...
    varargin{:});

end