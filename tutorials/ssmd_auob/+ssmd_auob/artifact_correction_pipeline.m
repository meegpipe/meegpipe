function myPipe = artifact_correction_pipeline(varargin)

import meegpipe.*;

import pset.selector.sensor_class;
import pset.selector.cascade;
import pset.selector.good_data;

nodeList = {};

%% Node: Import pre-processed data (from stage1 )
myImporter = physioset.import.physioset;
thisNode = node.physioset_import.new('Importer', myImporter);
nodeList = [nodeList {thisNode}];

% Node: copy
thisNode = node.copy.new('TempDir', @() tempdir);
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

%% Node: remove PWL noise
myNode = aar.pwl.new('IOReport', report.plotter.io);
nodeList = [nodeList {myNode}];

%% Node: ECG noise
myNode = aar.ecg.new;
nodeList = [nodeList {myNode}];

%% Sparse sensor noise
myNode = aar.sensor_noise.sparse_sensor_noise(...
    'Max',      125, ...
    'IOReport', report.plotter.io);
nodeList = [nodeList {myNode}];

%% low-pass filter
myNode = node.filter.new(...
    'Filter',           @(sr) filter.lpfilt('Fc', 42/(sr/2)), ...
     'DataSelector',    mySel, ...
    'Name',             'LP-filter-42Hz');
nodeList = [nodeList {myNode}];

%% Node: Reject EOG components using their topography
myNode = aar.eog.topo_generic(...
    'RetainedVar',      99.85, ...
    'MinCard',          1, ...
    'MaxCard',          10, ...
    'IOReport',         report.plotter.io);
nodeList = [nodeList {myNode}];

%% supervised BSS
myNode = aar.bss_supervised_single_node;
nodeList = [nodeList {myNode}];

% The actual pipeline

% Note that we manually set the tempory dir to be the local OS dir. This
% can make a real different in processing speed when the processing takes
% place in a grid node not directly attached to the data stage
myPipe = node.pipeline.new(...
    'NodeList',         nodeList, ...
    'Save',             true,  ...
    'Name',             'basic_preproc', ...
    'Queue',            'short.q', ...
    'TempDir',          @() tempdir, ...
    varargin{:});

