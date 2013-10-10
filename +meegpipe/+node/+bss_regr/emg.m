function obj = emg(varargin)
% EMG - Rejects EMG components
%
% See also: bss_regr


import meegpipe.node.bss_regr.bss_regr;
import spt.pca.pca;
import spt.bss.*;
import spt.criterion.sgini.sgini;
import pset.selector.sensor_class;
import pset.selector.good_data;
import pset.selector.cascade;
import misc.process_arguments;
import misc.split_arguments;

opt.BSS = efica.new;
opt.Var = 99.9;

[thisArgs, varargin] = split_arguments(fieldnames(opt), varargin);
[~, opt] = process_arguments(opt, thisArgs);

filtObj = @(sr) filter.hpfilt('fc', 0.75*30/(sr/2));
pcaObj = pca(...
    'Filter',       filtObj, ...
    'Var',          opt.Var/100, ...
    'MaxDimOut',    35);

% Build an empty bss_regr object
dataSel = cascade(sensor_class('Class', {'MEG', 'EEG'}), good_data);
obj = bss_regr(...
    'DataSelector',     dataSel, ...
    'Criterion',         spt.criterion.psd_ratio.emg, ...
    'PCA',              pcaObj, ...
    'BSS',               opt.BSS, ...
    'RegrFilter',       [], ...
    varargin{:});


obj = set_name(obj, 'bss_regr.emg');

end