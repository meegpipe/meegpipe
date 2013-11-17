function obj = emg(varargin)
% EMG - Rejects EMG components
%
% See also: bss_regr


import meegpipe.node.bss_regr.bss_regr;
import pset.selector.sensor_class;
import pset.selector.good_data;
import pset.selector.cascade;
import misc.process_arguments;
import misc.split_arguments;

myFeat = spt.feature.psd_ratio.emg;
myCrit = spt.criterion.threshold(myFeat, ...
    'MinCard',      1, ...
    'MaxCard',      5, ...
    'Max',          @(r) max(1, median(r) + 5*mad(r, 1)));
    

opt.BSS         = spt.bss.efica;
opt.RetainedVar = 99.9;
opt.MaxPCs      = 35;
opt.MinPCs      = @(d) ceil(0.05*d);
opt.Criterion   = myCrit;

[thisArgs, varargin] = split_arguments(fieldnames(opt), varargin);
[~, opt] = process_arguments(opt, thisArgs);


%% PCA
filtObj = @(sr) filter.hpfilt('fc', 0.75*30/(sr/2));
pcaObj = spt.pca(...
    'LearningFilter',       filtObj, ...
    'RetainedVar',          opt.RetainedVar, ...
    'MaxCard',              opt.MaxPCs, ...
    'MinCard',              opt.MinPCs);

%% Build an empty bss_regr object
dataSel = cascade(sensor_class('Class', {'MEG', 'EEG'}), good_data);
obj = bss_regr(...
    'DataSelector',     dataSel, ...
    'Criterion',        opt.Criterion, ...
    'PCA',              pcaObj, ...
    'BSS',              opt.BSS, ...
    'RegrFilter',       [], ...
    varargin{:});


obj = set_name(obj, 'bss_regr.emg');

end