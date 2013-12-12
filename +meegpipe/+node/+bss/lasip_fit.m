function obj = lasip_fit(varargin)

import misc.process_arguments;
import misc.split_arguments;
import pset.selector.sensor_class;
import pset.selector.good_data;
import pset.selector.cascade;

%% Process input arguments
opt.MinCard         = 2;
opt.MaxCard         = @(d) min(8, ceil(0.15*length(d)));
opt.RetainedVar     = 99.85; 
opt.BSS             = spt.bss.efica;

[thisArgs, varargin] = split_arguments(fieldnames(opt), varargin);
[~, opt] = process_arguments(opt, thisArgs);

%% PCA
myPCA = spt.pca(...
    'RetainedVar',      opt.RetainedVar, ...
    'MaxCard',          40);

%% Component selection criterion
myFeat1 = spt.feature.bp_var;
% Prevent at all cost that alpha or beta components are removed
myFeat2 = spt.feature.psd_ratio(...
    'TargetBand',   [0.1 6;14 20;45 55], ... % anything but alpha/beta
    'RefBand',      [6 14; 20 40] ...        % alpha and beta bands
    );
% How well does the LASIP filter track the signal? Do this in just a few
% epochs to speed up things
myFeat3 = spt.feature.sample_epochs(spt.feature.filter_fit.lasip, ...
    'EpochDur', @(sr) 20*sr, ...
    'NbEpochs', 10);

myCrit  = spt.criterion.threshold(myFeat1, myFeat2, myFeat3, ...
    'Max',     {10, @(fVal) prctile(fVal, 50), 0.5}, ...
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