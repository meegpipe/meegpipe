function obj = eog(varargin)

import misc.process_arguments;
import spt.criterion.*;


opt.Criteria        = { tfd.eog, psd_ratio.eog, topo_ratio.eog_egi256_hcgsn1};
opt.Weights         = [0.20 0.60 0.2];
opt.Percentile      = 80;
opt.MinCard         = 3;
opt.MaxCard         = 7;
opt.Min             = -Inf;
opt.Max             = @(rank) median(rank) + 2*mad(rank);
opt.Filter          = [];

[~, opt] = process_arguments(opt, varargin);

cfg = mrank.config;

fNames = fieldnames(opt);
for i = 1:numel(fNames),
    cfg.(fNames{i}) = opt.(fNames{i});
end

obj = mrank.mrank(cfg);


end