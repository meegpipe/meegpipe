function [y, idx] = proj(obj, data, varargin)
% PROJ - Forward spatial projection
%
%
% sources = proj(obj, data)
%
%
% See also: spt.generic.generic.proj, spt.spt, spt

import misc.center;
import misc.signal2hankel;
import spt.generic.generic;

if isempty(obj.W),
    error('You need to learn() first');
end

idx = find(obj.Selected);

if isempty(idx),
    y = [];
    return;
end

verbose      = is_verbose(obj);
verboseLabel = get_verbose_label(obj);

embedDim = get_config(obj,'EmbedDim');

if verbose,
    fprintf( ...
        [verboseLabel '%s projection into %d components...'], ...
        class(obj), numel(idx));
end

data = center(data);

if embedDim > 1,
    
    tmpData = signal2hankel(data(:,:), embedDim);
    y = obj.W(idx, :)*tmpData;
    
else
    
    y = obj.W(idx, :)*data;
    
end

% This is necessary so that in bproj we can use restore_sensors() to get
% back the original sensors
if isa(y, 'physioset.physioset')
    backup_sensors(y);
end

if verbose, fprintf( '[done]\n\n'); end


end

