function [y, idx] = proj(obj, data, varargin)
% PROJ - Forward spatial projection
%
%
% sources = proj(obj, data)
%
%
% See also: spt.generic.generic.proj, spt.spt, spt

% Documentation: class_spt_abtract_spt.txt
% Description: Forward spatial projection

import misc.center;
import misc.signal2hankel;
import spt.generic.generic;

W = projmat(obj);

if isempty(W),
    error('You need to learn() first');
end

idx = selection(obj);

if isempty(idx),
    y = [];
    return;
end

verbose      = is_verbose(obj);
verboseLabel = get_verbose_label(obj);

if verbose,
    fprintf( ...
        [verboseLabel '%s projection into %d components...'], ...
        class(obj), numel(idx));
end

data = center(data);

if obj.EmbedDim > 1,
    
    tmpData = signal2hankel(data(:,:), obj.EmbedDim);
    
    y = nan(size(tmpData));
    
    for i = 1:size(tmpdata, 2)
        W = obj.W(idx, :, i);
        y(:,i) = W*tmpData(:,i);
    end
    
else
    
    y = nan(size(data));
    
    for i = 1:size(data, 2)
        W = obj.W(idx, :, i);
        y(:,i) = W*data(:,i);
    end
    
end

if verbose, fprintf( '[done]\n\n'); end


end

