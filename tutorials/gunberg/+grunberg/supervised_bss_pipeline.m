function myPipe = supervised_bss_pipeline(varargin)

nodeList = {};

%% Importer node
myNode = meegpipe.node.physioset_import.new(...
    'Importer', physioset.import.physioset);
nodeList = [nodeList {myNode}];

%% Supervised BSS
mySelector = pset.selector.sensor_idx(5:32);
mySelector = pset.selector.cascade( ...
    mySelector, ...
    pset.selector.good_data);
myNode = aar.bss_supervised(...
    'DataSelector', mySelector, ...
    'RetainedVar',  99.999);
nodeList = [nodeList {myNode}];

%% Export to eeglab format
% What should we do with the bad data epochs when exporting to EEGLAB?
% reject=concatenate all good epochs
% flatten=set bad epochs to zero
% donothing=mark bad epochs with boundary events only
myExporter = physioset.export.eeglab('BadDataPolicy', 'reject');
myNode = meegpipe.node.physioset_export.new(...
    'Exporter', myExporter);
nodeList = [nodeList {myNode}];

myPipe = meegpipe.node.pipeline.new(...
    'NodeList', nodeList, ...
    'Name',     'supervised-bss', ...
    'Save',     true);


end