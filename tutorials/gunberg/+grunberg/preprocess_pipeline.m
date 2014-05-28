function myPipe = preprocess_pipeline(varargin)
% PREPROCESS_PIPELINE - A very basic preprocessing pipeline

import mperl.file.spec.catfile;
import pset.selector.good_data;
import pset.selector.cascade;

nodeList = {};

%% Node 1: data import
myImporter = physioset.import.poly5;
myNode = meegpipe.node.physioset_import.new('Importer', myImporter);
nodeList = [nodeList {myNode}];

%% Node 5: Low pass filtering
mySelector = pset.selector.sensor_idx(5:32);
myFilter = @(sr) filter.hpfilt('Fp', 0.5/(sr/2));
myNode = meegpipe.node.filter.new(...
    'Filter',       myFilter, ...
    'DataSelector', mySelector);
nodeList = [nodeList {myNode}];

%% Node 2: reject bad channels using variance
% We are only interested in channels 5 to 32
myCrit = meegpipe.node.bad_channels.criterion.var.new(...
    'Max', @(x) median(x) + 2*mad(x), 'MaxCard', 4);
myNode = meegpipe.node.bad_channels.new('Criterion', myCrit, ...
    'DataSelector', cascade(mySelector, good_data));
nodeList = [nodeList {myNode}];

%% Node 3: reject bad epochs using variance 
% We compute variance in sliding windows of duration 2 seconds and 50%
% overlap (i.e. the period of the windows is 1 second). We then reject
% those epochs with abnormally large variance
myNode = meegpipe.node.bad_epochs.sliding_window(1, 2, ...
    'DataSelector', mySelector);
nodeList = [nodeList, {myNode}];

%% Node 4: Smooth transitions between bad epochs
% The fact that we are ignoring bad epochs means that we may be introducing
% discontinuities in the signal. This node tries to minimize such
% discontinuities. The effect of this node is minimal so you could probably
% take it a away. But keeping it is unlikely to do any harm in any case.
myNode = meegpipe.node.smoother.new(...
    'DataSelector', cascade(mySelector, good_data));
nodeList = [nodeList {myNode}];

%% Node 5: Low pass filtering
myFilter = @(sr) filter.lpfilt('Fp', 43/(sr/2));
myNode = meegpipe.node.filter.new(...
    'Filter',       myFilter, ...
    'DataSelector', mySelector);
nodeList = [nodeList {myNode}];

%% Node 6: downsampling
% We have already downpass filtered our data so there is no point in using
% such a high sampling rate
myNode = meegpipe.node.resample.new('OutputRate', 250);
nodeList = [nodeList {myNode}];

%% Node 7: reject sparse sensor noise
% Does ICA on the data and tries to identify independent components that, 
% for being too spatially sparse, are likely to be due to sensor-specific
% noise sources. Such "sensor noise" components are rejected. 
myNode = aar.sensor_noise.new(...
    'RetainedVar',  99.9999, ...
    'MinCard',      21, ...
    'DataSelector', cascade(mySelector, good_data));
nodeList = [nodeList, {myNode}];

%% Node 8: reject cardiac components
myNode = aar.ecg.new;
nodeList = [nodeList, {myNode}];

%% Node 9: reject ocular components
myNode = aar.eog.new('IOReport', report.plotter.io);
nodeList = [nodeList, {myNode}];

%% Bad channel interpolation
myNode = meegpipe.node.chan_interp.new(...
    'NN',           2, ...
    'DataSelector', pset.selector.good_samples);
nodeList = [nodeList {myNode}];

%% Create the pipeline
myPipe = meegpipe.node.pipeline.new(...
    'Name',             'preprocess-pipeline', ...
    'NodeList',         nodeList, ...
    'Save',             true, ...
    'GenerateReport',   false, ...
    varargin{:});

end