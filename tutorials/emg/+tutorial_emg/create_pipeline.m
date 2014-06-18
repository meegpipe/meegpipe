function myPipe = create_pipeline(varargin)

% This cell array will store the list of nodes
nodeList = {};

% The first node: imports .set files into MATLAB
myImporter = physioset.import.eeglab;
myNode = meegpipe.node.physioset_import.new('Importer', myImporter);
nodeList = [nodeList {myNode}];

% The second node: uses a BSS-CCA filter to try to minimize EMG artifacts
% CCA is performed in sliding windows of 5 seconds (with 50% overlap) and the
% correction threshold is set to 75% (0%=no correction, 100%=output is flat).
% We use a very harsh correction to see the effects better
myNode = aar.emg.cca_sliding_window(...
    'WindowLength',     5, ...
    'WindowOverlap',    50, ...
    'CorrectionTh',     90);
nodeList = [nodeList {myNode}];

% The third node: store the results as an EEGLAB's .set file
myExporter = physioset.export.eeglab('FileName', 'cleaned-data');
myNode = meegpipe.node.physioset_export.new('Exporter', myExporter);
nodeList = [nodeList {myNode}];

% We are now ready to build the pipeline (which I decide to name 'emg-corr')
myPipe = meegpipe.node.pipeline.new(...
    'NodeList',        nodeList, ...
    'GenerateReport',  false, ...
    'Name',            'emg-corr', ...
    varargin{:});


end