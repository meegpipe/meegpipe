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

%% Node 5: PWL removal
myNode = meegpipe.node.bss.pwl;
nodeList = [nodeList {myNode}];

%% Node 6: ECG removal
myNode = meegpipe.node.bss.ecg;
nodeList = [nodeList {myNode}];

%% Node 7: EOG removal
myNode = meegpipe.node.bss.eog;
nodeList = [nodeList {myNode}];

%% Create the pipeline
% Note that we set property Save to true. If you wouldn't and your
% processing would take place on the grid (in the background) then your
% processed data would be lost forever...
%
% Property IOReport can be used to force the node generate an input-output
% report.
myPipe = meegpipe.node.pipeline.new(...
    'Name',             'ssmd_rs_artifacts', ...
    'NodeList',         nodeList, ...
    'Save',             true, ...
    'IOReport',         report.plotter.io, ...
    varargin{:});

end