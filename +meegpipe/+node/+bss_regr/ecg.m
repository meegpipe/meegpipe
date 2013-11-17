function obj = ecg(varargin)
% ECG - Rejects cardiac components
%
%
% See also: bss_regr

import meegpipe.node.bss_regr.bss_regr;
import misc.process_arguments;
import misc.isnatural;
import pset.selector.sensor_class;
import pset.selector.good_data;
import pset.selector.cascade;

filtObj = @(sr) filter.bpfilt('fp', [3/(sr/2) 1]);

opt.MinCard         = 0;
opt.MaxCard         = 1;
opt.RetainedVar     = 99.5;
opt.BSS             = spt.bss.efica('LearningFilter', filtObj);

[~, opt]    = process_arguments(opt, varargin);


%% PCA
pcaObj = spt.pca(...
    'RetainedVar',      opt.RetainedVar, ...
    'MaxCard',          40, ... %40
    'LearningFilter',   filtObj);

%% Component selection criterion
myFeat = spt.feature.qrs_erp('Filter',   filtObj);
myCrit = spt.criterion.threshold(myFeat, ...
    'MinCard',  opt.MinCard, ...
    'MaxCard',  opt.MaxCard);

%% Build an empty bss_regression object
dataSel = cascade(sensor_class('Class', {'MEG', 'EEG'}), good_data);
obj = bss_regr(...  
    'DataSelector',     dataSel, ...
    'Criterion',        myCrit, ...
    'PCA',              pcaObj, ...
    'BSS',              opt.BSS);


obj = set_name(obj, 'bss_regression.ecg');


end