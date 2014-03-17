function myPipe = artifact_correction_pipeline(varargin)

import meegpipe.node.*;

nodeList = {};

% Node: Import pre-processed data
myImporter = physioset.import.physioset;
thisNode = physioset_import.new('Importer', myImporter);
nodeList = [nodeList {thisNode}];

% Node: copy
thisNode = copy.new('TempDir', @() tempdir);
nodeList = [nodeList {thisNode}];

%% HP filter
mySel =  cascade(...
    sensor_class('Class', 'EEG'), ...
    good_data ...
    );
myNode = node.filter.new(...
    'Filter',         @(sr) filter.hpfilt('Fc', 0.5/(sr/2)), ...
    'DataSelector',   mySel, ...
    'Name',           'HP-filter-0.5Hz');
nodeList = [nodeList {myNode}];




% The actual pipeline

% Note that we manually set the tempory dir to be the local OS dir. This
% can make a real different in processing speed when the processing takes
% place in a grid node that is not directly attached to the data storage
% that holds the input data file.
myPipe = pipeline.new(...
    'NodeList',         nodeList, ...
    'Save',             true,  ...
    'Name',             'basic_preproc', ...
    'TempDir',          @() tempdir, ...
    varargin{:});

