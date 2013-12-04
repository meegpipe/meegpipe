function obj = emg(varargin)
% EMG - Filtering EMG artifacts using CCA

import misc.process_arguments;

opt.Correction    = 87.5;
opt.PCAVar        = 99.9;
opt.WindowOverlap = 75;
[~, opt] = process_arguments(opt, varargin);

myFilter = filter.cca('MinCorr', opt.Correction/100);

myFilter = filter.sliding_window(myFilter, ...
    'WindowLength',     @(sr) 5*sr, ...
    'WindowOverlap',    opt.WindowOverlap);

myFilter = filter.pca(...
    'PCFilter', myFilter, ...
    'PCA',      spt.pca('RetainedVar', opt.PCAVar));

obj = meegpipe.node.filter.new(...
    'Filter',   myFilter);

end