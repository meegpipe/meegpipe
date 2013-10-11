function obj = deselect(obj, idx)
% SELECT - Deselects one or more source dimensions
%
% 
% newObj = deselect(obj, idx)
%
% Where
%
% IDX is a vector of dimension indices. Alternatively, IDX can be either
% the string 'all', which will deselect all source dimensions (leading to
% an empty source space).
%
% NEWOBJ is identical to OBJ but has an "effective" source space that
% contains only the dimensions of OBJ source space having specified
% indices. 
%
%
% See also: select, clear_selection, abstract_spt, spt.spt

% Documentation: class_spt_abstract_spt.txt
% Description: Deselects a subset of source space dimensions

import misc.isnatural;
import exceptions.*

if nargin < 2, idx = []; end

if ischar(idx)
    
   switch lower(idx)      
       case 'all',
           idx = 1:size(obj.W,1);           
       case 'none', 
           idx = [];           
       otherwise
           error('Unknown index selection ''%s''', idx);
   end
   
elseif ~isnumeric(idx) || ~isvector(idx)
    
    throw(abstract_spt.InvalidArgument('idx'));
    
elseif any(idx < 1 | idx > obj.NbComp),
    
    idx = idx(idx < 1 | idx > obj.NbComp);    
    throw(InvalidArgValue('idx', sprintf(['Index %d exceeds number of ' ...
        'spatial components (%d)'], idx(1), obj.NbComp)));
    
end

obj.Selected(idx) = false;


end