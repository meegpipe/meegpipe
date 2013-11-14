function obj = emg(varargin)

import spt.criterion.sgini.sgini;

obj = sgini( ...
    'Percentile',   75, ...
    varargin{:});


end