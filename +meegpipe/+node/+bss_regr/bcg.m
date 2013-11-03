function obj = bcg(sr, varargin)
% BCG - Rejects BCG-like components
%
%
% See also: bss_regr


import meegpipe.node.bss_regr.bss_regr;
import meegpipe.node.abstract_node;
import misc.process_arguments;
import misc.isnatural;
import spt.criterion.terp.terp;
import spt.pca.pca;
import exceptions.*;
import physioset.event.std.qrs;
import pset.selector.sensor_class;
import spt.bss.jade.jade;
import misc.split_arguments;
import pset.selector.good_data;
import pset.selector.cascade;

if nargin < 1,
    sr = NaN;
end

if isempty(sr),
    throw(InvalidArgument('sr', ...
        'Must be provided'));
end

opt.BSS             = jade;
opt.MaxDimOut       = 35;
opt.PCAVar          = 0.99;
[thisArgs, varargin] = split_arguments(fieldnames(opt), varargin);

[~, opt]    = process_arguments(opt, thisArgs);

myFilter = @(sr) filter.lpfilt('fc', 20/(sr/2));
pcaObj = pca(...
    'Filter',       myFilter, ...
    'Var',          opt.PCAVar, ...
    'MaxDimOut',    opt.MaxDimOut);


% Build an empty bss_regr object
dataSel = cascade(good_data, sensor_class('Class', 'eeg'));
obj = bss_regr(... 
    'Criterion',        spt.criterion.terp.bcg, ...
    'PCA',              pcaObj, ...
    'BSS',              opt.BSS, ...
    'RegrFilter',       filter.mlag_regr('Order', 10), ...
    'DataSelector',     dataSel, ...
    varargin{:});

if isempty(get_name(obj)),
    obj = set_name(obj, 'bss_regr.bcg');
end

end