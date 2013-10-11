function obj = set_basis(obj, W, A)

if nargin < 3, A = []; end
if nargin < 2, return; end
    

obj.W = W;

if isempty(A) && ~isempty(obj.W),
    obj.A = pinv(obj.W);
elseif isempty(A) && isempty(W),
    obj.A = [];
elseif ~isempty(A),
    obj.A = A;
end

obj.Selected = true(1, size(W,1));

end