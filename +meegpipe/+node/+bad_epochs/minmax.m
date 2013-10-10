function obj = minmax(minVal, maxVal, varargin)
% MINMAX 

import meegpipe.node.bad_epochs.criterion.stat.stat;
import meegpipe.node.pipeline.pipeline;
import meegpipe.node.bad_epochs.bad_epochs;

if nargin < 2, maxVal = 80; end
if nargin < 1, minVal = -80; end

crit1 = stat(...
    'Statistic1',    @(x) max(x), ...
    'Statistic2',    @(x) max(x), ...
    'Percentile',    [0 100], ...
    'Max',           maxVal);

crit2 = stat(...
    'Statistic1',    @(x) min(x), ...
    'Statistic2',    @(x) min(x), ...
    'Percentile',    [0 100], ...
    'Min',           minVal);

obj1 = bad_epochs('Criterion', crit1, varargin{:});

obj2 = bad_epochs('Criterion', crit2, varargin{:});

obj = pipeline('NodeList', {obj1, obj2});



end