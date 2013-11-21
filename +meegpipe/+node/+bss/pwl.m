function obj = pwl(varargin)
% PWL - Default bss node configuration for PWL correction


import misc.process_arguments;
import misc.split_arguments;

%% Process user arguments
opt.MaxPCs          = 40;
opt.MinPCs          = 5;
opt.RetainedVar     = 99.75;

[thisArgs, varargin] = split_arguments(fieldnames(opt), varargin);

[~, opt] = process_arguments(opt, thisArgs);

%% PCA
myFilter = @(sr) filter.bpfilt('fp', [35 150]/(sr/2));
myPCA = spt.pca(  ...
        'LearningFilter',   myFilter, ...
        'RetainedVar',      opt.RetainedVar, ...
        'MaxCard',          opt.MaxPCs, ...
        'MinCard',          opt.MinPCs, ...
        'MaxCond',          1000); 
    
%% Component selection criterion
myFeat = spt.feature.psd_ratio.pwl;

myCrit = spt.criterion.threshold(myFeat, ...
    'Max',      30, ...
    'MaxCard',  2, ...
    'MinCard',  0);


end