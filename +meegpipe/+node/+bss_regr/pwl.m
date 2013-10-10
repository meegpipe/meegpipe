function obj = pwl(varargin)
% PWL - Rejects powerline components
%
%
% See also bss_regr

import meegpipe.node.*;
import spt.pca.pca;
import spt.bss.*
import misc.process_arguments;
import pset.selector.sensor_class;
import pset.selector.good_data;
import pset.selector.cascade;
import misc.split_arguments;
import misc.isnatural;

opt.MaxPCs          = 40;
opt.MinPCs          = 0;
opt.Var             = 99.75;

[thisArgs, varargin] = split_arguments(fieldnames(opt), varargin);

[~, opt] = process_arguments(opt, thisArgs);

pwlFilter = @(sr) filter.bpfilt('fp', [35 150]/(sr/2));
pcaObj = pca(  ...
        'Filter',       pwlFilter, ...
        'Var',          opt.Var/100, ...
        'MaxDimOut',    opt.MaxPCs, ...
        'MinDimOut',    opt.MinPCs, ...
        'MaxCond',      1000);
   
dataSel = cascade(sensor_class('Class', {'MEG', 'EEG'}), good_data);
obj = bss_regr.new(...
    'DataSelector',     dataSel, ...
    'Criterion',        spt.criterion.psd_ratio.pwl, ...
    'PCA',              pcaObj, ...
    'BSS',              multicombi.new, ...   
    'Name',             'bss_regression.pwl', ...
    varargin{:});

% This has been removed because I am afraid that it could actually
% introduce powerline noise in channels that were originally pwl-free
% 'RegrFilter',       filter.mlag_regr('Order', 1), ...


end