function myPipe = cleaning_pipeline(varargin)

import meegpipe.*;


USE_OGE = true;
DO_REPORT = true;
QUEUE = 'short.q@somerenserver.herseninstituut.knaw.nl';

nodeList = {};

%% Import
myImporter = physioset.import.physioset;
myNode = node.physioset_import.new('Importer', myImporter);
nodeList = [nodeList {myNode}];

%% copy data
nodeList = [nodeList {node.copy.new}];

%% high-pass filter
myNode = node.filter.new(...
    'Filter', @(sr) filter.hpfilt('Fc', 1/(sr/2)));
nodeList = [nodeList {myNode}];

%% low-pass filter
myNode = node.filter.new(...
    'Filter', @(sr) filter.hpfilt('Fc', 40/(sr/2)));
nodeList = [nodeList {myNode}];

%% bad channel rejection (using variance)
myNode = node.bad_channels.new;
nodeList = [nodeList {myNode}];

%% bad channel rejection (using xcorr)
myCrit = node.bad_channels.criterion.xcorr.new('Min', 0.1);
myNode = node.bad_channels.new('Criterion', myCrit);
nodeList = [nodeList {myNode}];

%% bad epochs
myNode = node.bad_epochs.sliding_window(1, 2, ...
    'Max',          @(x) prctile(x, 90));
nodeList = [nodeList {myNode}];

%% Node: Downsample
myNode = node.resample.new('OutputRate', 250);
nodeList = [nodeList {myNode}];

%% supervised BSS
myNode = aar.bss_supervised;
nodeList = [nodeList {myNode}];


%% Pipeline
myPipe = node.pipeline.new(...
    'NodeList',         nodeList, ...
    'Save',             true, ...
    'Parallelize',      USE_OGE, ...
    'GenerateReport',   DO_REPORT, ...
    'Name',             'cleaning_pipe', ...
    'Queue',            QUEUE ...
    );

