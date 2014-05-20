function myPipe = periodic_splitting_pipeline(varargin)
% PERIODIC_SPLITTING_PIPELINE - Split data in 10 minutes blocks

nodeList = {};

%% Node 1: data importer
myImporter = physioset.import.mff('Precision', 'single');
myNode = meegpipe.node.physioset_import.new('Importer', myImporter);

nodeList = [nodeList {myNode}];


%% Node 2: generate periodic events every 10 mins
myEvGen = physioset.event.periodic_generator('Period', 60*10, ...
    'Template', @(sampl, idx, data) physioset.event.event(sampl, ...
    'Type', '__SplitEvent', 'Value', idx));
myNode = meegpipe.node.ev_gen.new('EventGenerator', myEvGen);
nodeList = [nodeList {myNode}];

%% Node 3: split data
myEvSel = physioset.event.class_selector('Type', '__SplitEvent');
myNode = meegpipe.node.split.new('EventSelector', myEvSel);
nodeList = [nodeList {myNode}];

%% Create the pipeline object
myPipe = meegpipe.node.pipeline.new(...
    'NodeList',         nodeList, ...
    'Save',             false, ...
    'Name',             'periodic_splitting', ...
    varargin{:});

end