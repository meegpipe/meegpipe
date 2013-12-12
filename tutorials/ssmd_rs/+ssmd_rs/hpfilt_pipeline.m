function myPipe = hpfilt_pipeline(varargin)
% HPFILT_FIPELINE - Remove large data trends with a high-pass filter
%
% See also: ssmd_rs
import physioset.event.class_selector;
import pset.selector.sensor_label;

% Initialize the list of nodes that the pipeline will contain
nodeList = {};

%% Node 1: data import

% The default import precision of all data importers is double, but if you
% want double precision then it is a good idea to specify so anyways (to
% prepare for e.g. future versions of meegpipe changing the default
% precision).
myImporter = physioset.import.mff('Precision', 'double');
myNode = meegpipe.node.physioset_import.new('Importer', myImporter);
nodeList = [nodeList {myNode}];

%% Node 2: Remove data mean
% The main reason for having this node is to improve the visualization of
% the detrending step. 
myNode = meegpipe.node.center.new;
nodeList = [nodeList {myNode}];

%% Node 3: Detrending
myDataSel = pset.selector.sensor_class('Class', 'EEG');
myFilter  = @(sr) filter.hpfilt('fc', 1/(sr/2));
myNode    = meegpipe.node.filter.new(...
    'DataSelector',     myDataSel, ...
    'Filter',           myFilter, ...
    'NbChannelsReport', 5, ...        % how many channels to plot in report?
    'ShowDiffReport',   true ...      % Show also input-output difference in report?
    );
nodeList = [nodeList {myNode}];

%% Create the pipeline
% Important: set Save to true, or your results may be lost forever if you
% run the processing jobs through the grid (or even if you don't...)
myPipe = meegpipe.node.pipeline.new(...
    'Name',             'hpfilt_pipeline', ...
    'NodeList',         nodeList, ...
    'Save',             true, ...
    varargin{:});

end