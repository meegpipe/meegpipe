function myPipe = basic_preprocessing_pipeline(varargin)

import meegpipe.node.*;

nodeList = {};

% Node: Import raw data file
myImporter = physioset.import.mff('Precision', 'double');
thisNode = physioset_import.new('Importer', myImporter);
nodeList = [nodeList {thisNode}];

% Reject broken channels (a priori info)
mySel = pset.selector.sensor_label({'EEG 133$', 'EEG 145$', 'EEG 165$', ...
    'EEG 174$', 'EEG REF$'});
myCrit = node.bad_channels.criterion.data_selector.new(mySel);
myNode = node.bad_channels.new(...
    'Criterion', myCrit);
nodeList = [nodeList {myNode}];

% Node: detrend
mySel = pset.selector.sensor_class('Class', 'EEG');
thisNode = filter.detrend('DataSelector', mySel);
nodeList = [nodeList {thisNode}];

% Node: reject bad channels using variance
myCrit = bad_channels.criterion.var.new(...
    'NN',           10, ...
    'Min',          @(varValues) median(varValues) - 20, ...
    'Max',          @(varValues) min(median(varValues) + 10, prctile(varValues, 92)), ...
    'Filter',       @(sr) filter.lpfilt('fc', 40/(sr/2)), ...
    'Normalize',    false);
thisNode = bad_channels.new('Criterion', myCrit);
nodeList = [nodeList {thisNode}];

% Node: reject bad channels using cross correlation
myCrit = bad_channels.criterion.xcorr.new(...
    'NN',     10, ...
    'Min',    @(varValues) median(varValues) - 20, ...
    'Max',    Inf);
thisNode = bad_channels.new('Criterion', myCrit);
nodeList = [nodeList {thisNode}];

% Node: reject bad epochs
thisNode = bad_epochs.sliding_window;
nodeList = [nodeList {thisNode}];

% Node: Band-pass filter
myFilter = @(sr) filter.bpfilt('fp', [0.3 40]/(sr/2));
thisNode = filter.new('Filter', myFilter);
nodeList = [nodeList {thisNode}];

% Node: Downsample to 250 Hz
thisNode = resample.new('OutputRate', 250);
nodeList = [nodeList {thisNode}];

% The actual pipeline

% Note that we manually set the tempory dir to be the local OS dir. This
% can make a real different in processing speed when the processing takes
% place in a grid node that is not directly attached to the data storage
% that holds the input data file.
myPipe = pipeline.new(...
    'NodeList',         nodeList, ...
    'Save',             true,  ...
    'Name',             'basic_preproc', ...
    'TempDir',          @() tempdir, ...
    varargin{:});
