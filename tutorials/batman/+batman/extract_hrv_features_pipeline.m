function myPipe = extract_hrv_features_pipeline(varargin)
% EXTRACT_HRV_FEATURES_PIPELINE - HRV feature extraction pipeline
%
% See also: batman

import meegpipe.node.*;
import physioset.event.class_selector;
import pset.selector.sensor_label;

% Initialize the list of nodes that the pipeline will contain
nodeList = {};

%% Node 1: data import
myImporter = physioset.import.physioset('Precision', 'double');
myNode = physioset_import.new('Importer', myImporter);
nodeList = [nodeList {myNode}];

%% Node 2: QRS detection
myNode = qrs_detect.new;
nodeList = [nodeList {myNode}];

%% Note 3: ECG annotation using ecgpuwave + HRV feature extraction
myNode = ecg_annotate.new;
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