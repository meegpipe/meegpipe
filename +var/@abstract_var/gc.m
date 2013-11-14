function y = gc(obj, gamma, phi, theta, lags, varargin)
% GC - Multivariate Granger causality
%
%
% y = gc(obj, gamma, phi, theta, lags)
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
% ## Notes:
%
% * This function implements the multivariate extension of GC first
%   introduced in [2]. 
% 
% 
% ## References:
%
% [1] Barnett et al., 2009, Granger causality and transfer entropy are
% equivalent for Gaussian Variables, PRL 103 (23): 2-5
%
% [2] Geweke, J., 1982, J. Am. Stat. Assoc. 77, 304.
%
%
% See also: var.abstract_var, var.var, dynamics.var,
% var.abstract_var.pteDirIndex


% Documentation: class_var_abstract_var.txt
% Description: Granger Causality

if nargin < 5 || isempty(lags),
    lags = 1;
end

if nargin < 4,
    theta = setdiff(1:obj.NbDims, [gamma(:);phi(:)]);
end

y = 2*pte(obj, gamma, phi, theta, lags, varargin{:});


end