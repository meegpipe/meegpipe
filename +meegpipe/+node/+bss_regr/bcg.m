function obj = bcg(varargin)
% BCG - Rejects BCG-like components
%
%
% See also: bss_regr


import meegpipe.node.bss_regr.bss_regr;
import misc.process_arguments;
import physioset.event.std.qrs;
import pset.selector.sensor_class;
import misc.split_arguments;
import pset.selector.good_data;
import pset.selector.cascade;

opt.BSS             = spt.bss.jade;
opt.MaxPCs          = 35;
opt.RetainedVar     = 99;
[thisArgs, varargin] = split_arguments(fieldnames(opt), varargin);

[~, opt]    = process_arguments(opt, thisArgs);

%% PCA
myFilter = @(sr) filter.lpfilt('fc', 20/(sr/2));
pcaObj = spt.pca(...
    'LearningFilter',   myFilter, ...
    'RetainedVar',      opt.RetainedVar, ...
    'MaxCard',          opt.MaxPCs);


%% Component selection criterion
myFeat = spt.feature.erp.bcg;
myCrit = spt.criterion.threshold(myFeat, ...
    'MaxCard',      10, ...
    'MinCard',      3, ...
    'Max',          @(r) prctile(r, 70) ...
    );


%% Build an empty bss_regr object
dataSel = cascade(good_data, sensor_class('Class', 'EEG'));
obj = bss_regr(... 
    'Criterion',        myCrit, ...
    'PCA',              pcaObj, ...
    'BSS',              opt.BSS, ...
    'RegrFilter',       filter.mlag_regr('Order', 10), ...
    'DataSelector',     dataSel, ...
    varargin{:});

if isempty(get_name(obj)),
    obj = set_name(obj, 'bss_regr.bcg');
end

end