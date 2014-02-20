function obj = sparse_sensor_noise(varargin)
% SPARSE_SENSOR_NOISE - Correct noise generated at a single sensor

import misc.process_arguments;
import misc.split_arguments;
import pset.selector.sensor_class;
import pset.selector.good_data;
import pset.selector.cascade;

%% Process input arguments
opt.MinCard         = 2;
opt.MaxCard         = @(d) min(10, ceil(0.15*length(d)));
opt.RetainedVar     = 99.85; 
opt.BSS             = spt.bss.efica;

[thisArgs, varargin] = split_arguments(fieldnames(opt), varargin);
[~, opt] = process_arguments(opt, thisArgs);

%% PCA
myPCA = spt.pca(...
    'RetainedVar',      opt.RetainedVar, ...
    'MaxCard',          40);

%% Component selection criterion
myFeat1 = spt.feature.sgini('Nonlinearity', @(x) x.^2);
% Sometimes alpha and beta components have sparse topographies. By using a
% psd_ratio feature we are able to prevent any alpha/beta component being
% rejected by mistake
myFeat2 = spt.feature.psd_ratio(...
    'TargetBand',   [0.1 6;14 20;45 55], ... % anything but alpha/beta
    'RefBand',      [6 14; 20 40] ...        % alpha and beta bands
    );
myCrit  = spt.criterion.threshold(myFeat1, myFeat2, ...
    'Max',     {@(fVal) prctile(fVal, 75), 10}, ...
    'MinCard', opt.MinCard, ...
    'MaxCard', opt.MaxCard);

%% Build the bss node
dataSel = cascade(sensor_class('Class', {'EEG', 'MEG'}), good_data);
obj = meegpipe.node.bss.new(...
    'DataSelector', dataSel, ...
    'Criterion',    myCrit, ...
    'PCA',          myPCA, ...
    'BSS',          opt.BSS, ...
    'Name',         'bss.sparse_sensor_noise', ...
    varargin{:});

end