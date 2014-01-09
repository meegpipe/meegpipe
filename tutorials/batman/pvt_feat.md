PVT feature extraction
===


## Main processing script

````matlab
% Start in a completely clean state
close all;
clear all;
clear classes;

meegpipe.initialize;

% Import some utilities
import mperl.file.find.finddepth_regex_match;
import misc.get_hostname;

switch lower(get_hostname),
    case {'somerenserver', 'nin389'},
        % The directory where the split data files are located
        INPUT_DIR = ...
            '/data1/projects/meegpipe/batman_tut/gherrero/split_files_output';
        % The output directory where we want to store the features
        OUTPUT_DIR = ...
            '/data1/projects/meegpipe/batman_tut/gherrero/extract_pvt_features_output';
    otherwise
        INPUT_DIR = '/Volumes/DATA/tutorial/batman/split_files_output';
        OUTPUT_DIR = '/Volumes/DATA/tutorial/batman/extract_pvt_features_output';
end

% Some (optional) parameters that you may want to play with when experimenting
% with your processing pipeline
PARALLELIZE = true; % Should each file be processed in parallel?
DO_REPORT   = true; % Should full HTML reports be generated?

% Create an instance of the feature extraction pipeline
myPipe = batman.extract_pvt_features_pipeline(...
    'GenerateReport', DO_REPORT, ...
    'Parallelize',    PARALLELIZE);

% Note that we have not yet written function extract_pvt_feature_pipeline!

% Generate links to the relevant data files into the output directory. This
% step is equivalent to copying the relevant data files into the output
% directory but has the advantage of saving valuable disk space.
regex = 'split_files-.+_\d+\.pseth?';
splittedFiles = finddepth_regex_match(INPUT_DIR, regex, false);
somsds.link2files(splittedFiles, OUTPUT_DIR);
% Note that we use a regex that will match only those files that contain
% PVT events.
regex = '_pvt_\d+\.pseth$';
files = finddepth_regex_match(OUTPUT_DIR, regex);

% files should now be a cell array containing the full paths to the single
% sub-block .pseth files that were generated in the data splitting stage.
run(myPipe, files{:});
````


## Feature extraction pipeline

````matlab
function myPipe = extract_pvt_features_pipeline(varargin)
% EXTRACT_PVT_FEATURES_PIPELINE - PVT feature extraction pipeline
%
% See also: batman

import meegpipe.node.*;
import physioset.event.class_selector;
import pset.selector.sensor_label;

% Initialize the list of nodes that the pipeline will contain
nodeList = {};

%% Node 1: data import
myImporter = physioset.import.physioset;
myNode = physioset_import.new('Importer', myImporter);
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
````
