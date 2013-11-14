function obj = emg(varargin)


obj = spt.criterion.sgini.new( ...
    'Max',   @(ranks) prctile(ranks, 75), ...
    varargin{:});


end