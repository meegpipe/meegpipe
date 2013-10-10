function obj = eog(varargin)
% EOG - Rejects EOG components
%
%
% See also: bss_regr

import meegpipe.node.bss_regr.bss_regr;
import spt.pca.pca;
import spt.bss.*;
import spt.criterion.stopo2.stopo2;
import misc.process_arguments;
import pset.selector.sensor_class;
import pset.selector.good_data;
import pset.selector.cascade;
import misc.split_arguments;


%% Default arguments
opt.Var             = 99.5;
opt.MaxPCs          = 40;
opt.MinPCs          = @(d) ceil(0.1*d);
opt.BSS             = efica.new;
opt.Criterion       = spt.criterion.psd_ratio.eog; 

[thisArgs, varargin] = split_arguments(fieldnames(opt), varargin);

[~, opt] = process_arguments(opt, thisArgs);

filtObj = @(sr) filter.lpfilt('fc', 13/(sr/2));

%% PCA
pcaObj = pca(...
    'Var',          opt.Var/100, ...
    'MaxDimOut',    opt.MaxPCs, ...
    'MinDimOut',    opt.MinPCs, ...
    'MinSamples',   15, ...
    'Filter',       filtObj);

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