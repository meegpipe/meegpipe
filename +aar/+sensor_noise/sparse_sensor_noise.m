function obj = sparse_sensor_noise(varargin)
% SPARSE_SENSOR_NOISE - Correct noise generated at a single sensor

import misc.process_arguments;
import misc.split_arguments;
import pset.selector.sensor_class;
import pset.selector.good_data;
import pset.selector.cascade;

%% Process input arguments
opt.MinCard         = 1;
opt.MaxCard         = @(d) min(8, ceil(0.2*numel(d)));
opt.RetainedVar     = 99.85; 
opt.BSS             = spt.bss.efica;
opt.Max             = {@(fVal) ceil(0.6*numel(fVal))};

[thisArgs, varargin] = split_arguments(fieldnames(opt), varargin);
[~, opt] = process_arguments(opt, thisArgs);

%% PCA
myPCA = spt.pca(...
    'RetainedVar',      opt.RetainedVar, ...
    'MaxCard',          40);

%% Component selection criterion
myFeat1 = spt.feature.skurtosis;

myCrit  = spt.criterion.threshold(myFeat1, ...
    'Max',     opt.Max, ...
    'MinCard', opt.MinCard, ...
    'MaxCard', opt.MaxCard);

%% Build the bss node
dataSel = cascade(sensor_class('Class', {'EEG', 'MEG'}), good_data);
obj = meegpipe.node.bss.new(...
    'DataSelector', dataSel, ...
    'Criterion',    myCrit, ...
    'PCA',          myPCA, ...
    'BSS',          opt.BSS, ...
    'Name',         'sparse_sensor_noise', ...
    varargin{:});

end