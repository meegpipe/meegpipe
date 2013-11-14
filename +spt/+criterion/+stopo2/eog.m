function obj = eog(varargin)

import misc.process_arguments;
import spt.criterion.tfd.tfd;
import spt.criterion.stopo2.*;

opt.Criterion       = tfd.eog('MaxCard', 1, 'MinCard', 1);
opt.Percentile      = 70;
opt.MinCard         = 2;
opt.MaxCard         = 5;
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

obj = stopo2(cfg);


end