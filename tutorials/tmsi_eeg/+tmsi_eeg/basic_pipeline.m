function myPipe = basic_pipeline(varargin)
% BASIC_PIPELINE - A very basic preprocessing pipeline

import meegpipe.node.*;

nodeList = {};

%% Node 1: data import
myImporter = physioset.import.poly5;
myNode = physioset_import.new('Importer', myImporter);
nodeList = [nodeList {myNode}];

%% Node 2: Band pass filtering
myFilter = @(sr) filter.bpfilt('Fp', [1 40]/(sr/2));
myNode = filter.new('Filter', myFilter);
nodeList = [nodeList {myNode}];

%% Create the pipeline
myPipe = pipeline.new(...
    'Name',             'tsmi-basic-pipeline', ...
    'NodeList',         nodeList, ...
    'Save',             false, ...
    varargin{:});

end