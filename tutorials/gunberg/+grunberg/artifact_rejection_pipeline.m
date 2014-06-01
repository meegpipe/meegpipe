function myPipe = artifact_rejection_pipeline(varargin)
% ARTIFACT_REJECTION_PIPELINE - Minimize ECG, EOG and EMG artifacts
%
% See also: grunberg.main, grunberg.preprocessing_pipeline
import meegpipe.node.*;
import mperl.file.spec.catfile;
import pset.selector.good_samples;
import pset.selector.good_data;
import pset.selector.cascade;

nodeList = {};

%% Node 1: data import
% We import the results from the preprocessing pipeline
myImporter = physioset.import.physioset;
myNode = physioset_import.new('Importer', myImporter);
nodeList = [nodeList {myNode}];

%% Node 2: downsampling
% We deactivate the antialiasing filter because (1) it will distort the bad data
% epochs with large filtering artifacts (2) it is not needed for the non-bad
% data epochs, since they have already been lowpass filtered previously
myNode = meegpipe.node.resample.new(...
    'OutputRate',       250, ...
    'DataSelector',     pset.selector.all_data, ...
    'Antialiasing',     false);
nodeList = [nodeList {myNode}];

%% Node 8: reject cardiac components
mySelector = pset.selector.sensor_idx(5:32);
myNode = aar.ecg.new(...
    'DataSelector', cascade(mySelector, good_data), ...
    'IOReport',     report.plotter.io);
nodeList = [nodeList, {myNode}];

%% Node 7: reject sparse sensor noise
% This node does ICA on the data and identifies independent components that,
% for being too spatially sparse, are likely to be due to sensor-specific
% noise sources. Such "sensor noise" components are rejected.
myNode = aar.sensor_noise.new(...
    'RetainedVar',  99.999, ...
    'MinPCs',       20, ...
    'DataSelector', cascade(mySelector, good_data), ...
    'IOReport',     report.plotter.io ... % Compare input vs output
    );
nodeList = [nodeList, {myNode}];

%% Node 9: reject ocular components
myNode = aar.eog.new(...
    'MinCard',      1, ...      % Minimum number of rejected components
    'RetainedVar',  99.99, ...  % Retained variance by the PCA block
    'DataSelector', cascade(mySelector, good_data), ...
    'IOReport',     report.plotter.io);
nodeList = [nodeList, {myNode}];

%% Node 10: Bad channel interpolation
myNode = meegpipe.node.chan_interp.new(...
    'NN',           2, ...
    'DataSelector', good_samples);
nodeList = [nodeList {myNode}];

%% Node 11: Export to eeglab format
% What should we do with the bad data epochs when exporting to EEGLAB?
% reject=concatenate all good epochs
% flatten=set bad epochs to zero
% donothing=mark bad epochs with boundary events only
myExporter = physioset.export.eeglab('BadDataPolicy', 'reject');
myNode = meegpipe.node.physioset_export.new(...
    'Exporter', myExporter);
nodeList = [nodeList {myNode}];

%% Create the pipeline
myPipe = pipeline.new(...
    'Name',             'artifact-rejection-pipeline', ...
    'NodeList',         nodeList, ...
    'Save',             true, ...
    varargin{:});

end