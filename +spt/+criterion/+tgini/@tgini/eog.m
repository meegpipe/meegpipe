function obj = eog(varargin)

% Documentation: class_spt_criterion_tgini.txt
% Description: Static constructor for EOG component selection

import misc.process_arguments;

opt.Percentile      = 70;
opt.MinCard         = 2;
opt.MaxCard         = Inf;
opt.Min             = 0;
opt.Max             = 1;

[~, opt] = process_arguments(opt, varargin);

obj = spt.criterion.tgini(...
    'Percentile'    , opt.Percentile, ...
    'MinCard'       , opt.MinCard, ...
    'MaxCard'       , opt.MaxCard, ...
    'Min'           , opt.Min, ...
    'Max'           , opt.Max, ...
    varargin{:});



end