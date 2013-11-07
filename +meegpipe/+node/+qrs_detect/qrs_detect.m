function myNode = qrs_detect(varargin)

import meegpipe.node.*;

myNode = ev_gen.new(...
    'EventGenerator',   qrs_detect.ev_generator, ...
    'Name',             'qrs_detect', ...
    varargin{:});


end