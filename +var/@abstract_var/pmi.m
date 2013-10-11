function y = pmi(obj, gamma, phi, theta, lags)
% PMI - Partial Mutual Information
%
% y = pmi(obj, gamma, phi, theta, lags)
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
% ## Reference:
%
% ??
%
% See also: pte, gc, abstract_var

% Documentation: class_var_abstract_var.txt
% Description: Partial Mutual Information


import misc.isnatural;
import var.abstract_var;

if nargin < 5 || isempty(lags),
    lags = 1;
end

if nargin < 4 || isempty(theta),
    theta = [];
end
if nargin < 3,
    throw(abstract_spt.InvalidInput(...
        'At least 3 input arguments are expected'));
end


if any(lags<1) || ~all(isnatural(gamma)) || ndims(gamma)>2 || ...
        ~all(isnatural(phi)) || ndims(phi)>2 || ...
        ~all(isnatural(theta)) || ndims(theta) > 2,
    throw(abstract_spt.InvalidInput(...
        'The provided node indices are not valid'));
end

% PMI formula:
%
% PMI(X_Gamma <- X_Phi | X_Theta) = 
%   (1/2)*ln(|SigmaN|/|SigmaD|)
%

% Numerator: 
% SigmaN = Sigma(X_Gamma)-Sigma(X_Gamma, X_Theta^{-})*
%           *Sigma(X_Theta^{-})*Sigma(X_Gamma, X_Theta^{-})'


Sigma = acov(obj);
[SigmaMinus, SigmaMinusMinus] = acov(obj, lags);

SigmaGamma = Sigma(gamma, gamma);
colIndex = [];
colIndexD = [];
m = var_dimensionality(obj);
for i = 1:numel(lags)
    thisColIndex = (i-1)*m+1:i*m;    
    colIndex = [colIndex;thisColIndex(theta(:))'];  %#ok<*AGROW>
    colIndexD = [colIndexD;thisColIndex([phi(:);theta(:)])']; 
end
SigmaGammaThetaMinus = SigmaMinus(gamma, colIndex);
SigmaGammaThetaMinusMinus = SigmaMinusMinus(colIndex, colIndex);
SigmaN = SigmaGamma-...
    SigmaGammaThetaMinus*pinv(SigmaGammaThetaMinusMinus)*SigmaGammaThetaMinus';

% Denominator
% SigmaD = Sigma(X_Gamma)-Sigma(X_Gamma, X_Phi^{-} + X_Theta^{-})*
%           *Sigma(X_Phi^{-} + X_Theta^{-})*Sigma(X_Gamma, X_Phi^{-} + 
%            X_Theta^{-})'

SigmaGammaPhiThetaMinus = SigmaMinus(gamma, colIndexD);
SigmaGammaPhiThetaMinusMinus = SigmaMinusMinus(colIndexD, colIndexD);
SigmaD = SigmaGamma-...
    SigmaGammaPhiThetaMinus*pinv(SigmaGammaPhiThetaMinusMinus)*SigmaGammaPhiThetaMinus';

y = (1/2)*log(det(SigmaN)/det(SigmaD));

end

