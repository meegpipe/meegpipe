function obj = emg_burst(varargin)

import meegpipe.node.*;
import physioset.event.periodic_generator;
import physioset.event.class_selector;
import spt.bss.*;
import misc.process_arguments;
import misc.split_arguments;

opt.WindowLength    = 10; % in seconds
opt.EMGBand         = [40 100];
opt.EEGBand         = [2 30];
opt.MinCard         = 0;
opt.MaxCard         = 4;
opt.MaxDimOut       = 25;
opt.MinDimOut       = 2;
opt.BSS             = efica.new;
opt.Var             = 99.5;

[thisArgs, varargin] = split_arguments(fieldnames(opt), varargin);
[~, opt] = process_arguments(opt, thisArgs);
nodeList = {};

evType = '__emg_burst_chop';

%% Generate periodic events every 10 seconds
myGen = periodic_generator(...
    'Period',    opt.WindowLength, ...
    'Type',      evType, ...
    'Duration',  opt.WindowLength);
thisNode = ev_gen.new('EventGenerator', myGen);
nodeList = [nodeList {thisNode}];  %#ok<*AGROW>

%% A node to reject EMG components in the current window

myChopSelector = class_selector('Type', evType);

% We fine tune the criterion to be more conservative than with long
% duration EMG artifacts
myCrit = spt.criterion.psd_ratio.new(...
    'Band1',        opt.EMGBand, ...
    'Band2',        opt.EEGBand, ...
    'MaxCard',      opt.MaxCard, ...
    'MinCard',      opt.MinCard, ...
    'Max',          @(r) max(1, median(r) + 10*mad(r,1)));

filtObj = @(sr) filter.hpfilt('fc', 0.75*opt.EMGBand(1)/(sr/2));
myPCA = spt.pca.new('Var', opt.Var/100, 'MaxDimOut', opt.MaxDimOut, ...
    'MinDimOut', opt.MinDimOut, 'Filter', filtObj);

thisNode = bss_regr.emg(NaN, ...
    'ChopSelector',     myChopSelector, ...
    'Criterion',        myCrit, ...
    'BSS',              opt.BSS, ...
    'Var',              opt.Var, ...
    'PCA',              myPCA);
nodeList = [nodeList {thisNode}];  %#ok<*AGROW>

% Smoothing boundaries between analysis windows
thisNode = smoother.new(...
    'MergeWindow',   0.25, ...
    'EventSelector', myChopSelector);
nodeList = [nodeList {thisNode}];

obj = pipeline.new('NodeList', nodeList, 'Name', 'emg_burst', varargin{:});


end