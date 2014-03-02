function myPipe = artifact_rejection_pipeline(varargin)
% PREPROCESS_PIPELINE - A very basic preprocessing pipeline

import meegpipe.node.*;
import mperl.file.spec.catfile;

nodeList = {};

%% Node 1: data import
myImporter = physioset.import.physioset;
myNode = physioset_import.new('Importer', myImporter);
nodeList = [nodeList {myNode}];

%% Node 2: copy
myNode = copy.new;
nodeList = [nodeList {myNode}];

%% Node: remove ECG components
myNode = aar.ecg.new('IOReport', report.plotter.io);
nodeList = [nodeList {myNode}];

%% Node: remove EOG components
myNode = aar.eog.new('IOReport', report.plotter.io, 'RetainedVar', 99.99);
nodeList = [nodeList {myNode}];

%% Node 11: supervised BSS
myNode = aar.bss_supervised;
nodeList = [nodeList {myNode}];

%% Node 9: EMG
myNode = bss.emg(...
    'CorrectionTh',     25, ...
    'ShowDiffReport',   true, ...
    'IOReport',         report.plotter.io);
nodeList = [nodeList {myNode}];

%% Create the pipeline
myPipe = pipeline.new(...
    'Name',             'artifact-rejection-pipeline', ...
    'NodeList',         nodeList, ...
    'Save',             true, ...
    varargin{:});

end