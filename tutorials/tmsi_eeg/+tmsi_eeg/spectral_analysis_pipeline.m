function myPipe = spectral_analysis_pipeline(varargin)

import meegpipe.node.*;

nodeList = {};

%% Node 1: Data import
load('sensors_grunberg_subset');
myImporter = physioset.import.physioset('Sensors', mySensors);
myNode = physioset_import.new('Importer', myImporter);
nodeList = [ nodeList {myNode}];

%% Node 2: Copy the data
nodeList = [ nodeList {copy.new} ];

%% Node 5: reject bad channels
myCrit = bad_channels.criterion.var.new(...
    'Max', @(x) median(x) + 1.5*mad(x), 'MaxCard', 5);
myNode = bad_channels.new('Criterion', myCrit);
nodeList = [nodeList {myNode}];

%% Node 3: channel interpolation
myNode = chan_interp.new('NN', 2);
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
    'FrequencyRange', [4 40], ...
    'BOI',            myROI, ...     
    'LogData',        false);

myNode = spectra.new(...
    'ROI',          myROI, ...
    'PlotterPSD',   plotterPSD, ...
    'Channels2Plot', 1:28);
nodeList = [nodeList {myNode}];

% %% Node 5: Average reference
% nodeList = [nodeList {reref.avg}];
% 
% %% Node 6: And spectral analysis again
% myNode = spectra.new(...
%     'ROI',          myROI, ...
%     'PlotterPSD',   plotterPSD);
% nodeList = [nodeList {myNode}];

%% Create the pipeline
myPipe = pipeline.new(...
    'Name',             'spectral_analysis-pipeline', ...
    'NodeList',         nodeList, ...
    'Save',             false, ...
    varargin{:});

end

