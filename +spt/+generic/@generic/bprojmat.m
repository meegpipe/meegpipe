function C = bprojmat(obj)
% BPROJMAT - Backprojection matrix
%
% A = projmat(obj)
%
% Where
%
% A is a KxD mapping the D-dimensional source space to the K-dimensional
% measurement space.
%
%
% See also: projmat, project, bproject


C = obj.A(:, obj.Selected, :);

end
