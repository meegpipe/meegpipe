function obj = eog(varargin)

import misc.process_arguments;
import spt.criterion.mrank.*;
import spt.criterion.tfd.tfd;
import spt.criterion.stopo2.stopo2;


opt.Criteria        = { tfd, stopo2 };
opt.Weights         = [0.5 0.5];
opt.Percentile      = 75;
opt.MinCard         = 1;
opt.MaxCard         = 5;
opt.Min             = -Inf;
opt.Max             = Inf;
opt.Filter          = [];

[~, opt] = process_arguments(opt, varargin);

cfg = config;

fNames = fieldnames(opt);
for i = 1:numel(fNames),
    cfg.(fNames{i}) = opt.(fNames{i});
end

obj = mrank(cfg);


end