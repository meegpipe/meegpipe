function varargout = rowwise(varargin)
% ROWWISE
% Ensures rowwise data samples
%
% [x, y, z, ...] = rowwise(x, y, z, ...)
%
%

varargout = cell(1, nargin);
for i = 1:nargin
    if size(varargin{i}, 1) > size(varargin{i}, 2),
        varargout{i} = varargin{i}';
    end
end



end