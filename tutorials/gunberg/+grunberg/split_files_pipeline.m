function myPipe = split_files_pipeline(varargin)


import meegpipe.node.*;

nodeList = {};

%% Node 1: Data import
myNode = physioset_import.new('Importer', physioset.import.physioset);
nodeList = [ nodeList {myNode}];

%% Node 2-: Split epochs
[~, ~, ~, evType] = tmsi_eeg.epoch_definitions;

namingPolicy = @(physO, ev, evIdx) [get(ev, 'Type') '-' num2str(evIdx)];
for i = 1:numel(evType),
    evSel = physioset.event.class_selector('Type', evType{i});
    myNode = split.new( ...
        'DataSelector',      pset.selector.all_data, ...
        'EventSelector',     evSel, ...
        'SplitNamingPolicy', namingPolicy, ...
        'Name',              evType{i});
    nodeList = [nodeList {myNode}]; %#ok<AGROW>
end

%% Create the pipeline
myPipe = pipeline.new(...
    'Name',             'split_files-pipeline', ...
    'NodeList',         nodeList, ...
    'Save',             false, ...
    varargin{:});

end