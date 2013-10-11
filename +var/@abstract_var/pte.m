function y = pte(obj, gamma, phi, theta, lags, varargin)
% PTE - Partial Transfer Entropy
%
% y = pte(obj, gamma, phi, theta, lags)
%
% where
%
% GAMMA is a numeric array with the indices of the set of components
% towards which the PTE is to be assessed
%
% PHI is a numeric array with the indices of the components that form 
% the origin of the information flow
%
% THETA is a numeric array with the indices of the components with respect
% to which the TE should be partialized
%
% LAGS is a numeric array with the lags to use for building the past of the
% time series. By default, LAGS=1
%
%
% 
% ## References:
%
% [1] Schreiber, 2000, Measuring information transfer, Physical Review 
%     Letters, 85 (2): 461-4.
%
%
% See also: gc, pmi, abstract_var

% Documentation: class_var_abstract_var.txt
% Description: Partial Transfer Entropy

import misc.isnatural;
%import misc.abstract_var;

if nargin < 3,
    throw(abstract_var.InvalidInput(...
        'At least 3 input arguments are expected'));
end

if nargin < 4 || isempty(theta),
    theta = []; 
end

if nargin < 5 || isempty(lags),
    lags = 1;
end

if any(lags<1) || ~all(isnatural(gamma)) || ndims(gamma)>2 || ...
        ~all(isnatural(phi)) || ndims(phi)>2 || ...
        ~all(isnatural(theta)) || ndims(theta) > 2,
    throw(abstract_var.InvalidInput(...
        'The provided node indices are not valid'));
end

if numel(lags)>1,
    y = nan(1, numel(lags));
    for i = 1:numel(lags),
        y(i) = pte(obj, gamma, phi, theta, lags(i), varargin);
    end
    return;
end

% PTE formula:
%
% PTE(X_Gamma <- X_Phi | X_Theta) = 
%   (1/2)*ln(|SigmaN|/|SigmaD|)
%

% Numerator: 
% SigmaN = Sigma(X_Gamma)-Sigma(X_Gamma,X_Gamma^{-} + X_Theta^{-})*
%           *Sigma(X_Gamma^{-} + X_Theta^{-})*Sigma(X_Gamma,X_Gamma^{-} +
%           X_Theta^{-})'

Sigma = compute_acov(obj,[],[gamma(:);phi(:);theta(:)]);
[SigmaMinus, SigmaMinusMinus] = compute_acov(obj, lags,[gamma(:);phi(:);theta(:)]);

gamma = 1:numel(gamma);
phi = numel(gamma)+1:numel(gamma)+numel(phi);
theta = numel(gamma)+numel(phi)+1:numel(gamma)+numel(phi)+numel(theta);

SigmaGamma = Sigma(gamma, gamma);

colIndex = [];
colIndexD = [];
m = var_dimensionality(obj);
for i = 1:numel(lags)
    thisColIndex = (i-1)*m+1:i*m;    
    colIndex = [colIndex;thisColIndex([gamma(:);theta(:)])'];  %#ok<*AGROW>
    colIndexD = [colIndexD;thisColIndex([gamma(:);phi(:);theta(:)])']; 
end
SigmaGammaThetaMinus = SigmaMinus(gamma, colIndex);
SigmaGammaThetaMinusMinus = SigmaMinusMinus(colIndex, colIndex);
SigmaN = SigmaGamma-...
    SigmaGammaThetaMinus*pinv(SigmaGammaThetaMinusMinus)*SigmaGammaThetaMinus';

% Denominator
% SigmaD = Sigma(X_Gamma)-Sigma(X_Gamma, X_Gamma^{-} + X_Phi^{-} + X_Theta^{-})*
%           *Sigma(X_Gamma^{-} + X_Phi^{-} + X_Theta^{-})*Sigma(X_Gamma, X_Gamma^{-} +
%           X_Phi^{-} + X_Theta^{-})'

SigmaGammaPhiThetaMinus = SigmaMinus(gamma, colIndexD);
SigmaGammaPhiThetaMinusMinus = SigmaMinusMinus(colIndexD, colIndexD);
SigmaD = SigmaGamma-...
    SigmaGammaPhiThetaMinus*pinv(SigmaGammaPhiThetaMinusMinus)*SigmaGammaPhiThetaMinus';

y = (1/2)*log(det(SigmaN)/det(SigmaD));

end