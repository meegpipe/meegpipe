function obj = eog(varargin)
% EOG - Rejects EOG components
%
%
% See also: bss_regr

import meegpipe.node.bss_regr.bss_regr;
import misc.process_arguments;
import pset.selector.sensor_class;
import pset.selector.good_data;
import pset.selector.cascade;
import misc.split_arguments;


%% Default arguments
myFeat = spt.feature.psd_ratio.eog;
myCrit = spt.criterion.threshold(myFeat, ...
    'Max',      25, ...
    'MinCard',  2, ...
    'MaxCard',  @(lambda) ceil(0.25*numel(lambda)));

opt.RetainedVar     = 99.5;
opt.MaxPCs          = 40;
opt.MinPCs          = @(d) ceil(0.1*d);
opt.BSS             = spt.bss.efica;
opt.Criterion       = myCrit; 

[thisArgs, varargin] = split_arguments(fieldnames(opt), varargin);

[~, opt] = process_arguments(opt, thisArgs);


%% PCA
filtObj = @(sr) filter.lpfilt('fc', 13/(sr/2));
pcaObj = spt.pca(...
    'RetainedVar',              opt.RetainedVar, ...
    'MaxCard',                  opt.MaxPCs, ...
    'MinCard',                  opt.MinPCs, ...
    'MinSamplesPerParamRatio',  15, ...
    'LearningFilter',           filtObj);


%% Build an empty bss_regr object
dataSel = cascade(sensor_class('Class', {'MEG', 'EEG'}), good_data);
obj = bss_regr( ...
    'DataSelector',     dataSel, ...
    'Criterion',        opt.Criterion, ...
    'PCA',              pcaObj, ...
    'BSS',              opt.BSS, ...
    'Filter',           filter.lasip.eog, ...
    'RegrFilter',       filter.mlag_regr('Order', 5), ...
    'Name', 'bss_regr.eog', varargin{:});


end