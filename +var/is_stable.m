function bool = is_stable(A)
% IS_STABLE - True if a VAR model is stable
%
% bool = is_stable(A)
%
% where
%
% A is a (dim x dim x order) or (dim x (dim x order)) matrix of VAR
% coefficients. 
%
% BOOL is true if an only if the VAR model with cofficients A is stable.

dim = size(A, 1);

if size(A, 3) ~= 1,
    order = size(A, 3);
    A = reshape(A, dim, order*dim);
else
    order = size(A, 2)/dim;
end

lambda = eig([A; eye((order-1)*dim) zeros((order-1)*dim, dim)]);

if any(abs(lambda)>1),
    bool = false;
else
    bool = true;
end


end