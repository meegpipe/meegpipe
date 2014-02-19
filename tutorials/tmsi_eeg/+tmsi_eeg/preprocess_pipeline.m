function myPipe = preprocess_pipeline(varargin)
% PREPROCESS_PIPELINE - A very basic preprocessing pipeline

import meegpipe.node.*;

nodeList = {};

%% Node 1: data import
load('sensors_grunberg');

myImporter = physioset.import.poly5('Sensors', mySensors);
myNode = physioset_import.new('Importer', myImporter);
nodeList = [nodeList {myNode}];

%% Node 2: Select the relevant subset of data
mySelector = pset.selector.sensor_idx(5:32);
myNode = subset.new('DataSelector', mySelector);
nodeList = [nodeList {myNode}];

%% Node 3: Add events to mark the relevant data epochs
myEvGen = tmsi_eeg.grunberg_generator.default;
myNode = meegpipe.node.ev_gen.new(...
    'EventGenerator', myEvGen, ...
    'DataSelector',   pset.selector.all_data);
nodeList = [nodeList {myNode}];

%% Node 4: reject bad epochs (to minimize filteringa artifacts)
% For whatever reason, there are large outliers at the end of the Poly5
% files. 
myCrit = bad_epochs.criterion.stat.new(...
    'Max',              @(stats) median(stats)+2*mad(stats), ...
    'EpochStat',        @(x) max(x));
myNode = bad_epochs.sliding_window(5, 5, 'Criterion', myCrit);
nodeList = [nodeList {myNode}];


%% Node 5: reject bad channels
myCrit = bad_channels.criterion.var.new(...
    'Max', @(x) median(x) + 2*mad(x));
myNode = bad_channels.new('Criterion', myCrit);
nodeList = [nodeList {myNode}];

%% Node 4: center
% This is not really required but will make the report of the subsequent
% filtering node more meaningful (since filter input and output will have a
% more similar dynamic range). 
nodeList = [nodeList {center.new}];

%% Node 6: High pass filtering
myFilter = @(sr) filter.hpfilt('fc', 3/(sr/2));
myNode = filter.new('Filter', myFilter);
nodeList = [nodeList {myNode}];

%% Node 7: downsampling
myNode = resample.new('OutputRate', 250);
nodeList = [nodeList {myNode}];

%% Node 5: Low pass filtering
myFilter = @(sr) filter.lpfilt('fc', 43/(sr/2));
myNode = filter.new('Filter', myFilter);
nodeList = [nodeList {myNode}];

%% Node 3: reject bad epochs (again)
% Trying to get rid off large filtering artifacts
myCrit = bad_epochs.criterion.stat.new(...
    'Max',              @(stats) min(prctile(stats, 95), median(stats)+2*mad(stats)), ...
    'EpochStat',        @(x) max(x));
myNode = bad_epochs.sliding_window(1, 5, ...
    'Criterion',      myCrit, ...
    'DataSelector',   pset.selector.all_data);
nodeList = [nodeList {myNode}];

%% Node 6: reject ECG components
myNode = bss.ecg('RetainedVar', 99.99);
nodeList = [nodeList {myNode}];

%% Node 7: reject EOG components
myFeat1 = spt.feature.psd_ratio.eog;
myFeat2 = spt.feature.bp_var;
myCrit = spt.criterion.threshold('Feature', {myFeat1, myFeat2}, ...
    'Max',      {25 10}, ...
    'MinCard',  2, ...
    'MaxCard',  6);
myNode = bss.eog(...
    'RetainedVar',  99.99, ...
    'Criterion',    myCrit, ...
    'IOReport',     report.plotter.io, ...
    'Filter',       []);
nodeList = [nodeList {myNode}];

% %% Node 9: channel interpolation
% myNode = chan_interp.new;
% nodeList = [nodeList {myNode}];
% 
% %% Node 10: Split epochs
% [~, ~, ~, evType] = tmsi_eeg.epoch_definitions;
% 
% namingPolicy = @(physO, ev, evIdx) [get(ev, 'Type') '-' num2str(evIdx)];
% for i = 1:numel(evType),
%     evSel = physioset.event.class_selector('Type', evType{i});
%     
%     myNode = split.new( ...
%         'DataSelector',      pset.selector.all_data, ...
%         'EventSelector',     evSel, ...
%         'SplitNamingPolicy', namingPolicy, ...
%         'Name',              evType{i});
%     nodeList = [nodeList {myNode}]; %#ok<AGROW>
% end

%% Node 10: average reference
% nodeList = [nodeList {reref.avg}];

% %% Node 11-?: Spectral features
% % The bands of interest.
% % Features and topographies will be plotted for these bands only.
% myROI = mjava.hash;
% myROI('theta') = {[4 8], [4 40]};
% myROI('alpha') = {[8 12], [4 40]}; 
% myROI('beta1') = {[12 20], [4 40]}; 
% myROI('beta2') = {[20 40], [4 40]}; 
% 
% % Plot PSDs only between 4 and 40 Hz
% plotterPSD = @(sr) plotter.psd.psd(...
%             'FrequencyRange', [4 40]/(sr/2), ...
%             'LogData',        false);
% 
% % We need to compute spectral features for each epoch separately
% [~, ~, ~, evType] = tmsi_eeg.epoch_definitions;
% 
% for evItr = 1:numel(evType)
%  
%     evSel   = physioset.event.class_selector('Type', evType{evItr});
%     dataSel = pset.selector.event_selector(evSel);
%     myNode = spectra.new(...
%         'ROI',          myROI, ...
%         'Name',         ['spectra-' evType{evItr}], ...
%         'DataSelector', dataSel, ...
%         'PlotterPSD',   plotterPSD);
%     nodeList = [nodeList {myNode}];
%     
% end

%% Create the pipeline
myPipe = pipeline.new(...
    'Name',             'preprocess-pipeline', ...
    'NodeList',         nodeList, ...
    'Save',             true, ...
    varargin{:});

end