function obj = bcg(varargin)
% BCG - Static constructor for BCG identification purposes
%
% See also: topo_template

import spt.criterion.topo_template.topo_template;

obj = topo_template(...
    'Template', @(x) spt.criterion.topo_template.template_bcg(x), ...
    'MinCard',  1, ...
    'MaxCard',  8, ...
    varargin{:});


end