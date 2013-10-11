function C = projmat(obj)
% PROJMAT - Forward spatial projection matrix
%
% W = projmat(obj)
%
% Where
%
% W is a DxK matrix mapping the K-dimensional measurement space into the
% D-dimensional source space.
%
% See also: bprojmat, proj, bproj


C = obj.W(obj.Selected, :, :);

end
