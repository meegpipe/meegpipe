function [kopt, pk] = mdl(eigVal, n)
% MDL - Minimum Description Length criterion
%
% [kopt, pk] = mdl(eigVal, n)
%
% Where
%
% EIGVAL are the eigenvalues of the PCA decomposition
%
% N is the number of data samples
%
% KOPT is the selected model order
%
% PK is a vector with the criterion values for increasing model orders
%
% 
% See also: spt.pca, spt.pca.aic, spt.pca.mibs, spt

% Documentation: class_spt_pca.txt
% Description: Minimum Description Length criterion

import spt.pca.pca;

eigVal  = sort(eigVal, 'descend');
eigVal  = eigVal./max(eigVal);
dOrig   = numel(eigVal);

% Otherwise, we will run into log(0) below
eigVal(eigVal < eps) = [];

logpk = pca.logpk(eigVal);

d = numel(eigVal);
k = 1:d;
pk = -n.*(d-k).*logpk + (k./2).*(2*d-k).*log(n);

[~, kopt] = min(pk); 

pk = [pk NaN(1, dOrig-d)];

end