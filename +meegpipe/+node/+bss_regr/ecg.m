function obj = ecg(varargin)
% ECG - Rejects cardiac components
%
%
% See also: bss_regr

import meegpipe.node.bss_regr.bss_regr;
import misc.process_arguments;
import misc.isnatural;
import spt.pca.pca;
import spt.bss.jade.jade;
import spt.bss.*;
import spt.criterion.qrs_erp.qrs_erp;
import pset.selector.sensor_class;
import pset.selector.good_data;
import pset.selector.cascade;


opt.mincard         = 0;
opt.maxcard         = 1;
opt.Var             = 99.5;

[~, opt]    = process_arguments(opt, varargin);


filtObj = @(sr) filter.bpfilt('fp', [3/(sr/2) 1]);

% PCA
pcaObj = pca(...
    'Var',          opt.Var/100, ...
    'MaxDimOut',    40, ... %40
    'Filter',       filtObj);

% Component selection criterion
critObj   = qrs_erp(NaN, ...
    'MinCard',      opt.mincard, ...
    'MaxCard',      opt.maxcard, ...
    'Filter',       filtObj);

% Build an empty bss_regression object
dataSel = cascade(sensor_class('Class', {'MEG', 'EEG'}), good_data);
obj = bss_regr(...  
    'DataSelector',     dataSel, ...
    'Criterion',        critObj, ...
    'PCA',              pcaObj, ...
    'BSS',              efica.new('Filter', filtObj));


obj = set_name(obj, 'bss_regression.ecg');


end