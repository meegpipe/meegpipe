function myPipe = spectral_analysis_pipeline(varargin)

import meegpipe.node.*;

nodeList = {};

%% Node 1: Data import
myNode = physioset_import.new('Importer', physioset.import.physioset);
nodeList = [ nodeList {myNode}];

%% Node 2: Copy the data
nodeList = [ nodeList {copy.new} ];

%% Node 3: channel interpolation
myNode = chan_interp.new;
nodeList = [nodeList {myNode}];

%% Node 4: Spectral analysis
% The bands of interest.
% Features and topographies will be plotted for these bands only.
myROI = mjava.hash;
myROI('theta') = {[4 8], [4 40]};
myROI('alpha') = {[8 12], [4 40]};
myROI('beta1') = {[12 20], [4 40]};
myROI('beta2') = {[20 40], [4 40]};

% Plot PSDs only between 4 and 40 Hz
plotterPSD = @(sr) plotter.psd.psd(...
    'FrequencyRange', [4 40]/(sr/2), ...
    'LogData',        false);

myNode = spectra.new(...
    'ROI',          myROI, ...
    'PlotterPSD',   plotterPSD);
nodeList = [nodeList {myNode}];

%% Node 5: Average reference
nodeList = [nodeList {reref.avg}];

%% Node 6: And spectral analysis again
myNode = spectra.new(...
    'ROI',          myROI, ...
    'PlotterPSD',   plotterPSD);
nodeList = [nodeList {myNode}];

%% Create the pipeline
myPipe = pipeline.new(...
    'Name',             'preprocess-pipeline', ...
    'NodeList',         nodeList, ...
    'Save',             false, ...
    varargin{:});

end

