function A = random_topology(dim, order, minCoeffTh)
% RANDOM_TOPOLOGY - Generate VAR coefficients with a random topology
%
% A = random_topology(dim, order, minCoeffTh)
%
% where
%
% DIM is the dimensionality of the VAR model, i.e. the number of nodes in
% the network. Defaults to 2. 
%
% ORDER is the order of the VAR model. Defaults to 1.
%
% MINCOEFFTH is the minimum value allowed for the generated VAR
% coefficients (in absolute value). You can enforce the generation of a
% dense topology by setting MINCOEFFTH to something greater than zero.
% Defaults to 0.
%
% A is a DIM x (DIMxORDER) matrix of VAR coefficients. The corresponding
% model is stable but has otherwise no topological structure.
%
%
% See also: var


if nargin < 3 || isempty(minCoeffTh), minCoeffTh = 0; end
if nargin < 2 || isempty(order), order = 1; end
if nargin < 1 || isempty(dim), dim = 2; end

MAX_ITER = 100000;

iter    = 0;
lambda  = Inf;
range   = [0 1];
A       = 0;
while iter < MAX_ITER && ...
        (any(abs(lambda)>1) || any(abs(A(:))<minCoeffTh))
    
   V=orth(rand(dim*order,dim*order));
   U=orth(rand(dim*order,dim*order));   
   lambdatmp = range(1)+(range(2)-range(1))*rand(dim*order,1);   
   A1 = V*diag(lambdatmp)*U';
   A = A1(1:dim,:);
   lambda = eig([A; eye((order-1)*dim) zeros((order-1)*dim,dim)]);        
   iter = iter + 1;
   
end

if iter >= MAX_ITER, 
    error(['Could not find a stable topology for dim = %d ; order = %d ; ' ...
        'minCoeffTh = %.2f'], dim, order, minCoeffTh);
end


end