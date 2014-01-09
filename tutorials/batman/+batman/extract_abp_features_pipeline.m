function myPipe = extract_abp_features_pipeline(varargin)
% EXTRACT_ABP_FEATURES_PIPELINE - ABP feature extraction pipeline
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

%% Node 2: copy input physioset to prevent modifying the input .pseth files
myNode = copy.new;
nodeList = [nodeList {myNode}];

%% Node 3: Calibrate the ABP channel
myNode = operator.new(...
    'Operator',         @(x) batman.calibrate_abp(x), ...
    'DataSelector',     pset.selector.sensor_label('Portapres'), ...
    'Name',             'abp-calib');
nodeList = [nodeList {myNode}];

%% Node 4: ABP onset detection
myNode = abp_beat_detect.new(...
    'DataSelector',     pset.selector.sensor_label('Portapres')...
    );
nodeList = [nodeList {myNode}];


%% Node 5: Extract ABP features
myNode = abp_features.new(...
    'DataSelector',     pset.selector.sensor_label('Portapres') ...
    );
nodeList = [nodeList {myNode}];

%% Create the pipeline
% Note that we set property Save to false because we are not interested in
% the actual physioset data values but only on the features that are
% extracted from the ABP time-series. The latter are stored in the
% generated HTML reports and thus we don't need to save a binary copy of
% the physioset that comes at the output of our pipeline.
myPipe = pipeline.new(...
    'Name',             'batman-abp', ...
    'NodeList',         nodeList, ...
    'Save',             false, ...
    varargin{:});

end