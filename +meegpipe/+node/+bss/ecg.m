function obj = ecg(varargin)
% ECG - Default bss node configuration for ECG rejection

import misc.process_arguments;
import misc.split_arguments;
import pset.selector.sensor_class;
import pset.selector.good_data;
import pset.selector.cascade;

%% Process input arguments

myFilter = @(sr) filter.bpfilt('fp', [3/(sr/2) 48/(sr/2);52/(sr/2) 1]);

opt.MinCard         = 0;
opt.MaxCard         = 2;
opt.CorrTh          = 0.6; % Correlation threshold
opt.RetainedVar     = 99.75; 
opt.BSS             = spt.bss.efica('LearningFilter', myFilter);

[thisArgs, varargin] = split_arguments(fieldnames(opt), varargin);

[~, opt] = process_arguments(opt, thisArgs);

%% PCA
myPCA = spt.pca(...
    'RetainedVar',      opt.RetainedVar, ...
    'MaxCard',          40, ... 
    'LearningFilter',   myFilter);

%% Component selection criterion
myFeat = spt.feature.qrs_erp('Filter', myFilter);
myCrit = spt.criterion.threshold(myFeat, ...
    'MinCard',  opt.MinCard, ...
    'MaxCard',  opt.MaxCard, ...
    'Max',      0.6);

%% Build the bss node
dataSel = cascade(sensor_class('Class', {'MEG', 'EEG'}), good_data);
obj = meegpipe.node.bss.new(...  
    'DataSelector',     dataSel, ...
    'Criterion',        myCrit, ...
    'PCA',              myPCA, ...
    'BSS',              opt.BSS, ...
    'RegrFilter',       filter.mlag_regr('Order', 5), ...
    'Name',             'bss.ecg', ...
    varargin{:});


end