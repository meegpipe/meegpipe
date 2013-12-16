function A = tree_topology(dim, order, th)
% TREE_TOPOLOGY - Generates VAR coefficients with a tree-like topology
%
% A = tree_topology(dim, order)
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

if nargin < 3, th = []; end
if nargin < 2 || isempty(order), order = 1; end
if nargin < 1 || isempty(dim), dim = 2; end

% Note that this function calls random_topology, which also iterates. So do
% not use a very large number here or you may end up with an endless
% iteration.
MAX_ITER = 10;

if isempty(th),
    % Try to figure out a reasonable value for th
    th = Inf;
    for i = 1:MAX_ITER,
       Atmp = random_topology(dim, order);
       th = min(th, min(abs(Atmp(:))));
    end
end

A0 = random_topology(dim, order, th);

if dim < 2, A = A0; return; end

A0 = reshape(A0, dim, dim, order); 

A = 2; % Initialize to an unstable model
iter = 0;

while (~is_stable(A) && iter <= MAX_ITER)
    
    alreadySinks = 1;
    forbidden    = cell(dim,1);
    A = A0;
    sources = 1;
    
    for i = 1:order
       A(:,:,i) = diag(diag(squeeze(A0(:,:,i)))); 
    end
    
    while ~isempty(setdiff(1:dim, alreadySinks))
        count = 1;
        newSources = [];
        while count <= numel(sources)
            idx = setdiff(1:dim, [count alreadySinks forbidden{sources(count)}]);
            idxPerm = randperm(numel(idx));
            idxNonZero = idx(idxPerm(1:min(numel(idx),2)));
            for j = 1:order,
                A([sources(count) idxNonZero], sources(count),  j) = ...
                    A0([sources(count) idxNonZero], sources(count),  j);
            end
            newSources = [newSources idxNonZero]; %#ok<AGROW>
            for i = 1:numel(idxNonZero)
                forbidden{idxNonZero(i)} = [forbidden{idxNonZero(i)} sources(count)];
            end
            alreadySinks = [alreadySinks idxNonZero];  %#ok<AGROW>
            count = count + 1;
        end
        sources = newSources;
    end
  
    iter = iter + 1;
    
end

if iter > MAX_ITER,
    throw(UnstableModel('unable to generate a stable sparse topology'));
end


end