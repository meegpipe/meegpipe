function [kopt, pk] = aic(eigVal, n)
% AIC - Akaike's Information Criterion
%
% [kopt, pk] = aic(eigVal, n)
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
% See also: spt.pca, spt.pca.mdl, spt.pca.mibs, spt

% Documentation: class_spt_pca.txt
% Description: Akaike's information criterion

import spt.pca.pca;

eigVal  = sort(eigVal, 'descend');
eigVal  = eigVal./max(eigVal);
dOrig   = numel(eigVal);

% Otherwise, we will run into log(0) below
eigVal(eigVal < eps) = [];

logpk = pca.logpk(eigVal);
d = numel(eigVal);
k = 1:d;
pk = -2*n.*(d-k).*logpk + 2*k.*(2*d-k);

if all(diff(pk) > 0),
    % If monotonically increasing, better not to do anything
    kopt = numel(eigVal);
else
    [~, kopt] = min(pk);
end

pk = [pk NaN(1, dOrig-d)];

end