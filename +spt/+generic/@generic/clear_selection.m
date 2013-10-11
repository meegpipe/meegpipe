function obj = clear_selection(obj)
% CLEAR_SELECTION - Clears any source space dimensions selection
%
% newObj = clear_selection(obj)
%
% 
% Where
%
% NEWOBJ is identical to OBJ, but has removed any existing selection of
% source space dimensions. This is equivalent to:
%
% newObj = select(obj, 'all');
%
%
% See also: spt.generic.generic.select, spt.generic.generic, spt

% Description: Clears selection of source space dimensions
% Documentation: class_spt_abstract_spt.txt

obj = select(obj, 'all');




end