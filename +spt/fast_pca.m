function y = fast_pca(M, k)
% FAST_PCA - A simple PCA function
%
% y = fast_pca(M, k)
%
% Where
%
% 
%
% See also: spt.pca

if k < 1,
    % Then it is a variance threshold
end

C = cov(M', 1);

if isa(M, 'pset.mmappset'),
    transpose(M);
end

[V, D]              = eig(C);
[~, I]              = sort(diag(D), 'descend');
V                   = V(:,I);
tmp                 = diag(D);
D                   = tmp(I);
  
tmp = D.^(-.5);

W = diag(tmp(1:k))*V(:,1:k)';

y = W*M;


end