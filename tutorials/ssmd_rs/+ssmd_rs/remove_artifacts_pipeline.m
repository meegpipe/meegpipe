function myPipe = remove_artifacts_pipeline(varargin)
% REMOVE_ARTIFACTS_PIPELINE - Remove PWL, ECG and EOG artifacts
%
% See also: batman

import physioset.event.class_selector;
import pset.selector.sensor_label;

% Initialize the list of nodes that the pipeline will contain
nodeList = {};

%% Node 1: data import
myImporter = physioset.import.physioset;
myNode = meegpipe.node.physioset_import.new('Importer', myImporter);
nodeList = [nodeList {myNode}];

%% Node 2: copy
myNode = meegpipe.node.copy.new;
nodeList = [nodeList {myNode}];

%% Node 3: downsampling
myNode = meegpipe.node.resample.new('OutputRate', 250);
nodeList = [nodeList {myNode}];

%% Node 4: bad channels rejection using variance

% This is actually identical to the default criterion used by the bad
% channels rejection node. So you could have just done:
% myNode = meegpipe.node.bad_channes.new;
% I do it this way to illustrate how you can change the behavior of the bad
% channels (variance-based) rejection criterion.
myCrit = meegpipe.node.bad_channels.criterion.var.new(...
    'MinCard',  0, ...
    'MaxCard',  @(dim) ceil(0.2*dim), ...
    'Min',      @(chanVars) median(chanVars) - 20, ...
    'Max',      @(chanVars) median(chanVars) + 20*mad(chanVars), ...
    'LogScale', true);
myNode = meegpipe.node.bad_channels.new('Criterion', myCrit);
nodeList = [nodeList {myNode}];

%% Node 5: reject bad channels using local cross correlation
myCrit = meegpipe.node.bad_channels.criterion.xcorr.new(...
    'Min',  @(nnCorr) prctile(nnCorr, 1) ...
    );
myNode = meegpipe.node.bad_channels.new('Criterion', myCrit);
nodeList = [nodeList {myNode}];

%% Node 6: reject bad epochs (those that exceed +150 or -150 microvolts)
myCrit = meegpipe.node.bad_epochs.criterion.stat.new(...
    'ChannelStat',   @(x) max(abs(x)), ...
    'EpochStat',     @(x) max(x), ...
    'MinCard',       @(x) prctile(x, 1), ...  % Reject at least 1%
    'MaxCard',       @(x) prctile(x, 25), ... % Reject at most 25%
    'Min',           -150, ...
    'Max',           150 ...
    );
myNode = meegpipe.node.bad_epochs.new('Criterion', myCrit);
nodeList = [nodeList {myNode}];

%% Node 4: PWL removal
myNode = meegpipe.node.bss.pwl;
nodeList = [nodeList {myNode}];

%% Node 5: ECG removal
myNode = meegpipe.node.bss.ecg;
nodeList = [nodeList {myNode}];

%% Node 6: EOG removal
myNode = meegpipe.node.bss.eog;
nodeList = [nodeList {myNode}];

%% Create the pipeline
% Note that we set property Save to false because we are not interested in
% the actual physioset data values but only on the HRV features that are
% extracted from the ECG time-series. The latter are stored in the
% generated HTML reports and thus we don't need to save a binary copy of
% the physioset that comes at the output of our pipeline.
myPipe = pipeline.new(...
    'Name',             'batman-hrv', ...
    'NodeList',         nodeList, ...
    'Save',             false, ...
    varargin{:});

end