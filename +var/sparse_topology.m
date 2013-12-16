function A = sparse_topology(dim, order)
% SPARSE_TOPOLOGY - Generate VAR coefficients with a sparse topology
%
% A = sparse_topology(dim, order)
%
% where
%
% DIM is the dimensionality of the VAR model, i.e. the number of nodes in
% the network. Defaults to 2. 
%
% ORDER is the order of the VAR model. Defaults to 1.
%
% See also: var

import var.random_topology;
import var.exceptions.UnstableModel;
import var.is_stable;

if nargin < 2 || isempty(order), order = 1; end
if nargin < 1 || isempty(dim), dim = 2; end

% Note that this function calls random_topology, which also iterates. So do
% not use a very large number here or you may end up with an endless
% iteration.
MAX_ITER = 10;

A0 = random_topology(dim, order);

if dim < 2, A = A0; return; end

A0 = reshape(A0, dim, dim, order);

lambda = Inf;
iter   = 0;
while (any(abs(lambda) > 1) && iter <= MAX_ITER)
    A = A0;
    % Break the loop
    index = setdiff(1:dim^2,1:(dim+1):dim^2);
    index = index(randperm((dim^2-dim)));
    index = index(1:(dim^2-dim)/2);
    
    for i = 1:order
        tmp = squeeze(A(:,:,i));
        tmp(index) = 0;
        A(:, :, i) = tmp;
    end
    
    % Check that model is stable (it should be!)
    A = reshape(A, dim, dim*order);
    lambda = eig([A; eye((order-1)*dim) zeros((order-1)*dim, dim)]);
    
    iter = iter + 1;
end

if ~is_stable(A),
    throw(UnstableModel('unable to generate a stable sparse topology'));
end


end