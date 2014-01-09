function myPipe = lasip_pipeline(varargin)
% LASIP_PIPELINE - Remove large data trends with a polynomial filter
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
myNode     = meegpipe.node.physioset_import.new('Importer', myImporter);
nodeList   = [nodeList {myNode}];

%% Node 2: Remove data mean
% The main reason for having this node is to improve the visualization of
% the detrending step. 
myNode = meegpipe.node.center.new;
nodeList = [nodeList {myNode}];

%% Node 3: Detrending
% We will detrend using a LASIP filter, developed by some of my former
% colleagues:
% http://www.cs.tut.fi/~lasip/
%
% The LASIP filter may be much more effective than the polynomial filter at
% removing sharp (large-amplitude) variations in your EEG data. The
% downsides are that (1) the current implementation of the LASIP filter is
% terribly slow, and (2) the LASIP filter has quite a few parameters which
% can be ticky to set for optimal results. For now, we will just use the
% default LASIP filter (or almost ... ask your tutor about the GetNoise
% parameter).
myFilter = filter.lasip('GetNoise', true);

% It is very important to remember to set the DataSelector property of the
% node appropriately so that only the desired channels are filtered. In
% our case, only the EEG data should be processed:
myDataSel = pset.selector.sensor_class('Class', 'EEG'); 
myNode   = meegpipe.node.filter.new(...
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
    'Name',             'lasip_pipeline', ...
    'NodeList',         nodeList, ...
    'Save',             true, ...
    varargin{:});

end