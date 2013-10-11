function obj = eog(varargin)

import misc.process_arguments;
import spt.criterion.*;


opt.Criteria        = { tfd.eog, psd_ratio.eog};
opt.Weights         = [0.40 0.60];
opt.Percentile      = 90;
opt.MinCard         = 3;
opt.MaxCard         = 6;
opt.Min             = -Inf;
opt.Max             = @(rank) median(rank) + 4*mad(rank);
opt.Filter          = [];

[~, opt] = process_arguments(opt, varargin);

cfg = mrank.config;

fNames = fieldnames(opt);
for i = 1:numel(fNames),
    cfg.(fNames{i}) = opt.(fNames{i});
end

obj = mrank.mrank(cfg);


end