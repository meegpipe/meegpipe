function obj = select(obj, idx)
% SELECT - Selects a subset of source-space dimensions
%
% 
% newObj = select(obj, idx)
%
% Where
%
% IDX is a vector of dimension indices. Alternatively, IDX can be either
% the string 'all'. The latter will select all source dimensions leading to
% identical "effective" and "true" source spaces.
%
% NEWOBJ is identical to OBJ but has an "effective" source space that
% contains only the dimensions of OBJ source space having specified
% indices. 
%
%
% See also: deselect, clear_selection, abstract_spt, spt.spt, spt

import misc.isnatural;
import spt.generic.generic;

if nargin < 2, idx = []; end

if islogical(idx),
    idx = find(idx);
end

if ischar(idx)
   switch lower(idx)      
       case 'all',
           idx = 1:size(obj.W,1);                 
       otherwise
           error('Unknown index selection ''%s''', idx);
   end
elseif ~isnumeric(idx) || ndims(idx) > 2
    throw(abstract_spt.InvalidArgument('idx'));
elseif any(idx < 1 | idx > obj.NbComp),
    idx = idx(idx < 1 | idx > obj.NbComp);    
    error('Source index %d is out of range', idx(1));
end

obj.Selected(idx) = true;


end