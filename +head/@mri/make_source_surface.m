function obj = make_source_surface(obj, depth)
% MAKE_SOURCE_SURFACE - Creates source dipoles on brain surface

if nargin < 2 || isempty(depth), depth = 3.5+2.5; end

obj.SourceSpace.pnt = source_layer(obj, depth);
obj.SourceSpace.depth = repmat(depth, size(obj.SourceSpace.pnt,1), 1);


end