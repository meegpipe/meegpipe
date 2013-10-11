function obj = bcg(varargin)
% BCG - Static constructor for BCG identification purposes
%
% See also: xcorr

import pset.selector.sensor_class;
import spt.criterion.xcorr.xcorr;

obj = xcorr(...
    'Selector',         sensor_class('Type', 'ECG'), ...
    'SummaryFunc',      @(x) max(x), ...
    'Min',              0.2, ...
    varargin{:});


end