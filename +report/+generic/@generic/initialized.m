function val = initialized(obj)
% INITIALIZED - Tests whether report has been initialized
%
% bool = initialized(obj)
%
% See also: initialize

% Documentation: class_generic.txt
% Description: Tests whether report has been initialized

import misc.is_valid_fid;

val = ~isempty(get_fid(obj));

end
