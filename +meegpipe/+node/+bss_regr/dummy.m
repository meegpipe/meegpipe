function obj = dummy(varargin)

import meegpipe.node.*;
import pset.selector.sensor_class;
import pset.selector.good_data;
import pset.selector.cascade;

pca = spt.pca.new(...
    'Var',          0.999, ...
    'MaxDimOut',    45);

critObj = spt.criterion.dummy.new;

dataSel = cascade(sensor_class('Class', {'MEG', 'EEG'}), good_data);

obj = bss_regr.new(...
    'DataSelector',         dataSel, ...
    'Criterion',            critObj, ...
    'PCA',                  pca, ...
    'Reject',               false, ...
    'Name', 'dummy', varargin{:});


end