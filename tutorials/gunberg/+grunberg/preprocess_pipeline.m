function myPipe = preprocess_pipeline(varargin)
% PREPROCESS_PIPELINE - A very basic preprocessing pipeline
%
% See also: grunberg.main, grunberg.artifact_rejection_pipeline

import mperl.file.spec.catfile;
import pset.selector.good_data;
import pset.selector.cascade;
import pset.selector.good_samples;

nodeList = {};

%% Node 1: data import
myImporter = physioset.import.poly5;
myNode = meegpipe.node.physioset_import.new('Importer', myImporter);
nodeList = [nodeList {myNode}];

%% Node 2: Generate events marking the onsets of epochs of interest
% We need to do this now because in the next node (downsampling) we are
% considering as input to the downsamples only the "good" data samples.
myNode = meegpipe.node.ev_gen.new(...
    'EventGenerator', grunberg.grunberg_generator.default);
nodeList = [nodeList {myNode}];

%% Node 3: Export to fieldtrip format
myNode = meegpipe.node.physioset_export.new(...
    'Exporter', physioset.export.fieldtrip);
nodeList = [nodeList {myNode}];

%% Node 4: reject bad channels using variance
% We are only interested in channels 5 to 32
mySelector = pset.selector.sensor_idx(5:32);
myCrit = meegpipe.node.bad_channels.criterion.var.new(...
    'Max', @(x) median(x) + 2*mad(x), 'MaxCard', 8);
myNode = meegpipe.node.bad_channels.new('Criterion', myCrit, ...
    'DataSelector', cascade(mySelector, good_data));
nodeList = [nodeList {myNode}];

%% Node 5: Bad channel interpolation
% Note that the interpolated channels will remained marked as bad.
myNode = meegpipe.node.chan_interp.new(...
    'NN',           2, ...
    'DataSelector', good_samples);
nodeList = [nodeList {myNode}];


%% Node 6: remove large signal fluctuations using a LASIP filter

% Setting the "right" parameters of the filter involves quite a bit of
% trial and error. These values seemed OK to me but we should check
% carefully the reports to be sure that nothing went terribly wrong. In
% particular you should ensure that the LASIP filter is not removing
% valuable signal. It is OK if some residual noise is left after the LASIP
% filter so better to be conservative here.
myScales =  [20, 29, 42, 60, 87, 100, 126, 140, 182, 215, 264, 310, 382];

myFilter = filter.lasip(...
    'Decimation',       12, ...
    'GetNoise',         true, ... % Retrieve the filtering residuals
    'Gamma',            15, ...
    'Scales',           myScales, ...
    'WindowType',       {'Gaussian'}, ...
    'VarTh',            0.1);

% This object especifies which subset of data should be processed by the
% node. In this case we want to process only the EEG data, and ignore any
% other modalities.
myNode = meegpipe.node.filter.new(...
    'Filter',           myFilter, ...
    'Name',             'lasip', ...
    'DataSelector',     mySelector, ...
    'ShowDiffReport',   true ...
    );
nodeList = [nodeList {myNode}];

%% Node 7: reject bad epochs using variance 
% We compute the log(max(abs(x)) in sliding windows of duration of 5 seconds
% and a temporal shift between correleative windows of 2 second. We then
% reject those epochs with abnormally large variance
myCrit = meegpipe.node.bad_epochs.criterion.stat.new(...
    'Max',          @(x) max(prctile(x, 80), min(log(500), prctile(x, 95))), ...
    'ChannelStat',  @(x) log(prctile(abs(x), 90)));
myNode = meegpipe.node.bad_epochs.sliding_window(2, 6, ...
    'DataSelector', cascade(mySelector, good_data), ...
    'Criterion',    myCrit);
nodeList = [nodeList, {myNode}];

%% Node 8: Smooth transitions between bad epochs
% The fact that from the previous node onwards we are ignoring bad epochs
% means that we may be introducing discontinuities in the signal. This node
% tries to minimize such discontinuities. 
myNode = meegpipe.node.smoother.new(...
    'DataSelector', cascade(mySelector, good_data));
nodeList = [nodeList {myNode}];

%% Node 9: Band pass filtering 
% We do the low-pass filtering after removing bad epochs because otherwise
% the sharp noise transients in the data will produce huge filtering
% artifacts.
myFilter = @(sr) filter.bpfilt('Fp', [1 43]/(sr/2));
myNode = meegpipe.node.filter.new(...
    'Filter',       myFilter, ...
    'DataSelector', cascade(mySelector, good_data));
nodeList = [nodeList {myNode}];

%% Create the pipeline
myPipe = meegpipe.node.pipeline.new(...
    'Name',             'preprocess-pipeline', ...
    'NodeList',         nodeList, ...
    'Save',             true, ...
    'GenerateReport',   true, ...
    varargin{:});

end