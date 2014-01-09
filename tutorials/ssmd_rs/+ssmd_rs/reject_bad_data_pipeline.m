function myPipe = reject_bad_data_pipeline(varargin)
% REJECT_BAD_DATA - Downsampling and rejection of bad data channels/samples
%
% See also: ssmd_rs

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

%% Node 3: downsampling to 250 Hz
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
    'MaxCard',  @(chanVars) ceil(0.2*numel(chanVars)), ...
    'Min',      @(chanVars) median(chanVars) - 20, ...
    'Max',      @(chanVars) median(chanVars) + 3*mad(chanVars), ...
    'LogScale', true);
myNode = meegpipe.node.bad_channels.new('Criterion', myCrit);
nodeList = [nodeList {myNode}];

%% Node 5: reject bad channels using local cross correlation
myCrit = meegpipe.node.bad_channels.criterion.xcorr.new(...
    'Min',  @(nnCorr) prctile(nnCorr, 1));
myNode = meegpipe.node.bad_channels.new('Criterion', myCrit);
nodeList = [nodeList {myNode}];

%% Node 6: reject bad epochs (those that exceed +120)
myCrit = meegpipe.node.bad_epochs.criterion.stat.new(...
    'ChannelStat',   @(x) max(abs(x)), ...
    'EpochStat',     @(x) iqr(x), ...
    'MinCard',       @(epochRankings) floor(0.01*numel(epochRankings)), ...  % Reject at least 1%
    'MaxCard',       @(epochRankings) ceil(0.25*numel(epochRankings)), ...   % Reject at most 25%
    'Min',           @(statVal) median(statVal) - 5*mad(statVal), ...
    'Max',           @(statVal) median(statVal) + 5*mad(statVal) ...
    );
myNode = meegpipe.node.bad_epochs.sliding_window(...
    .5,  ...    % The period of the sliding windows (seconds)
    2,   ...    % The duration of the sliding windows (seconds)
    'Criterion', myCrit);
nodeList = [nodeList {myNode}];

%% Create the pipeline
% Note that we set property Save to true. If you wouldn't and your
% processing would take place on the grid (in the background) then your
% processed data would be lost forever...
myPipe = meegpipe.node.pipeline.new(...
    'Name',             'ssmd_rs_bad_data', ...
    'NodeList',         nodeList, ...
    'Save',             true, ...
    varargin{:});

end