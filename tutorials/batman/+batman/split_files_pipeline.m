function myPipe = split_files_pipeline(varargin)
% SPLIT_FILES_PIPELINE - Splits BATMAN .mff files into single sub-block files

import meegpipe.node.*;

% Initialize the list of nodes that the pipeline will contain
nodeList = {};

%% Node 1: Covert .mff files into a physioset object
myImporter = physioset.import.mff('Precision', 'single');
myNode = physioset_import.new('Importer', myImporter);

nodeList = [nodeList {myNode}];

%% Node 2-: Split each sub-block within each experimental manipulation block

% This event selector selects the first PVT event in every PVT sub-block
myEvSel = batman.pvt_selector;

% The offset of each sub-block with respect to the PVT sub-block onset
off = mjava.hash;
off('baseline') = -9*60;
off('pvt')      = 0;
off('rs')       = 7*60;
off('arsq')     = 12*60;

% The duration of each sub-block
dur = mjava.hash;
dur('baseline') = 9*60;
dur('pvt')      = 7*60;
dur('rs')       = 5*60;
dur('arsq')     = 3.5*60;

% A cell array with the names of every sub-block
sbNames = keys(dur);

for sbItr = 1:numel(sbNames)
   
    namingPolicy = @(physO, ev, evIdx) ...
        batman.split_naming_policy(physO, ev, evIdx, sbNames{sbItr});
    
    myNode = split.new(...
        'DataSelector',      [], ...
        'EventSelector',     myEvSel, ...
        'SplitNamingPolicy', namingPolicy, ...
        'Duration',          dur(sbNames{sbItr}), ...
        'Offset',            off(sbNames{sbItr}), ...
        'Name',              sbNames{sbItr});
    
    nodeList = [nodeList {myNode}]; %#ok<AGROW>
end

%% Create the pipeline object
myPipe = meegpipe.node.pipeline.new(...
    'NodeList',         nodeList, ...
    'Save',             false, ...
    'Name',             'split_files', ...
    varargin{:});

end