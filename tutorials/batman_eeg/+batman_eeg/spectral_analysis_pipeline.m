function myPipe = spectral_analysis_pipeline(varargin)

import meegpipe.node.*;

nodeList = {};

%% Node 1: Data import
myImporter = physioset.import.physioset;
myNode = physioset_import.new('Importer', myImporter);
nodeList = [ nodeList {myNode}];

%% Node 2: Copy the data
nodeList = [ nodeList {copy.new('Path', @() tempdir)} ];

%% Node 5: reject bad channels (again!)
myCrit = bad_channels.criterion.var.new(...
    'Max', @(x) median(x) + 1.5*mad(x), 'MaxCard', 5);
myNode = bad_channels.new('Criterion', myCrit, 'GenerateReport', false);
nodeList = [nodeList {myNode}];

%% Node 3: channel interpolation
myNode = chan_interp.new('NN', 4, 'GenerateReport', false);
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
    'FrequencyRange', [3 40], ...
    'BOI',            myROI, ...     
    'LogData',        false);

% Do not compute spectral features from peripheral channels (probably more
% affected by noise). 
sens  = sensors.eeg.from_template('egi256');
xyz  = cartesian_coords(sens); 
z = xyz(:,3);
z = z - min(z);
z = z./max(z);
isPeripheral = z < 0.4;
channels = labels(subset(sens, ~isPeripheral));
channels = cellfun(@(x) ['^' x '$'], channels, 'UniformOutput', false);

myNode = spectra.new(...
    'ROI',          myROI, ...
    'PlotterPSD',   plotterPSD, ...
    'Channels2Plot', {channels}, ...
    'Channels',     [num2cell(1:257)';{channels}]);
nodeList = [nodeList {myNode}];

%% Create the pipeline
myPipe = pipeline.new(...
    'Name',             'spectral_analysis', ...
    'NodeList',         nodeList, ...
    'Save',             false, ...
    varargin{:});



end