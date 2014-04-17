function myPipe = extract_pvt_features_pipeline(varargin)
% EXTRACT_PVT_FEATURES_PIPELINE - PVT feature extraction pipeline
%
% See also: batman
import meegpipe.node.*;
import physioset.event.class_selector;
import pset.selector.sensor_label;
import misc.process_arguments;
import misc.split_arguments;

opt.Importer = physioset.import.physioset;
[thisArgs, varargin] = split_arguments(opt, varargin);
[~, opt] = process_arguments(opt, thisArgs);

% Initialize the list of nodes that the pipeline will contain
nodeList = {};

%% Node 1: data import
myNode = physioset_import.new('Importer', opt.Importer);
nodeList = [nodeList {myNode}];

%% Node 2: Extract event features
evSelector = batman.rsp_selector; 
featList = {'Time', 'Sample', 'cel', 'obs', 'rsp', 'rtim', 'trl'};
thisNode = ev_features.new(...
    'EventSelector',    evSelector, ...
    'Features',         featList);
nodeList = [nodeList {thisNode}];

%% Create the pipeline
% Note that we set property Save to false because we are not interested in
% the actual physioset data values but only on the PVT features that are
% extracted from the PVT and RSP events. 

myPipe = pipeline.new(...
    'Name',             'batman-pvt', ...
    'NodeList',         nodeList, ...
    'Save',             false, ...
    varargin{:});

end