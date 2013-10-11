function template = template_bcg(data, varargin)
% TEMPLATE_BCG - Use BCG ERP waveform as template
%
%
% See also: topo_template

import physioset.search_processing_history;

nodeList = search_processing_history(data, 'obs');

if isempty(nodeList),
    template = [];
    warning('spt:criterion:topo_template:template_bcg:NoTemplate', ...
        'No template could be built based on processing history');
    return;
end


template = get_bcg_erp(nodeList{1});



end