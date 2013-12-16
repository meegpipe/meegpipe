function y = cmi(obj, gamma, phi, lags)
% CMI - Conditional Mutual Information
%
% y = cmi(obj, gamma, phi, lags)
%
% where
%
% GAMMA is a numeric array with the indices of the set of components
% towards which the CMI is to be assessed
%
% PHI is a numeric array with the indices of the components that form 
% the origin of the information flow
%
% LAGS is a numeric array with the lags to use for building the past of the
% time series. By default, LAGS=1
%
% 
% ## Reference:
%
% [1] Palus et al., 2001, Synchronization as adjustment of information
%     rates: detection from bivariate time series, Physical Review E,
%     63(4):1-6. 
%
%
% See also: pte, pmi, gc, abstract_var

% Documentation: class_var_abstract_var.txt
% Description: Conditional Mutual Information


import misc.isnatural;
import var.abstract_var;

if nargin < 3,
    throw(abstract_var.InvalidInput(...
        'At least 3 input arguments are expected'));
end

if nargin < 4 || isempty(lags),
    lags = 1;
end

if any(lags<1) || ~all(isnatural(gamma)) || ndims(gamma)>2 || ...
        ~all(isnatural(phi)) || ndims(phi)>2,
    throw(abstract_spt.InvalidInput(...
        'The provided node indices are not valid'));
end

y = pte(obj, gamma, phi, [], lags);