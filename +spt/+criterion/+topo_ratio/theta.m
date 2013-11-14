function obj = theta(varargin)

import spt.criterion.topo_ratio.topo_ratio;
import spt.criterion.topo_ratio.label_regex;

obj = topo_ratio(...
    'SensorSelectorNum', @(x) label_regex(x, 'EEG 21$'), ...
    'SensorSelectorDen', @(x) label_regex(x, 'EEG 137$'), ...
    varargin{:});
    

end