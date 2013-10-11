function obj = ecg(varargin)

import spt.criterion.acf.acf;
import misc.process_arguments;

% Modify the object properties that have not been set by the user
opt.Period          = .9;   % R-peak period in seconds
opt.PeriodMargin    = 0.3;  % In seconds
opt.Min             = 0.18; % Normalized corr coeff
opt.MaxCard         = 5;
opt.Percentile      = 80;
opt.MADs            = 3;

[~, opt] = process_arguments(opt, varargin);



obj = acf(...
    'MADs',         opt.MADs, ...  
    'Period',       opt.Period, ...
    'PeriodMargin', opt.PeriodMargin, ...
    'Min',          opt.Min, ...
    'MaxCard',      opt.MaxCard, ...
    'Percentile',   opt.Percentile, ...
    varargin{:});


end