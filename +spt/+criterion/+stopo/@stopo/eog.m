function obj = eog(varargin)

import misc.process_arguments;
import spt.criterion.tkurtosis.tkurtosis;
import spt.criterion.stopo.*;

opt.Criterion       = tkurtosis('MaxCard', 2, 'MinCard', 2);
opt.Percentile      = 70;
opt.MinCard         = 2;
opt.MaxCard         = Inf;
opt.Min             = 0;
opt.Max             = 1;

[~, opt] = process_arguments(opt, varargin);

cfg = config(...
    'Percentile'    , opt.Percentile, ...
    'MinCard'       , opt.MinCard, ...
    'MaxCard'       , opt.MaxCard, ...
    'Min'           , opt.Min, ...
    'Max'           , opt.Max, ...
    'Criterion'     , opt.Criterion, ...
    varargin{:});

obj = stopo(cfg);


end