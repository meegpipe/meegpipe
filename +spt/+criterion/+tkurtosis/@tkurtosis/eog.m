function obj = eog(varargin)


import misc.process_arguments;
import spt.criterion.tkurtosis.*;

opt.Percentile      = 70;
opt.MinCard         = 2;
opt.MaxCard         = 4;
opt.Min             = 0;
opt.Max             = 1;
opt.MedFiltOrder    = 5;

[~, opt] = process_arguments(opt, varargin);

cfg = config(...
    'Percentile'    , opt.Percentile, ...
    'MinCard'       , opt.MinCard, ...
    'MaxCard'       , opt.MaxCard, ...
    'Min'           , opt.Min, ...
    'Max'           , opt.Max, ...
    'MedFiltOrder'  , opt.MedFiltOrder, ...
    varargin{:});

obj = tkurtosis(cfg);


end