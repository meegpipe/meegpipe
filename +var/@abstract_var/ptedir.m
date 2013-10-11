function diVal = ptedir(obj, Gamma, Phi, Theta, lag)
% PTEDIR - PTE-based directionality index
%
% y = ptedir(obj, gamma, phi, theta, lags)
%
% where
%
% GAMMA is a numeric array with the indices of the set of components
% towards which the directionality index is to be assessed
%
% PHI is a numeric array with the indices of the components that form 
% the origin of the information flow
%
% THETA is a numeric array with the indices of the components with respect
% to which the Transfer Entropy should be partialized
%
% LAGS is a numeric array with the lags to use for building the past of the
% time series. By default, LAGS=1
%
% Y is the directionality index, which is a number in the range [-1 1]. If
% Y < 0 then the information flow is the opposite direction to the one
% provided. Otherwise, the information flow agrees to the provided
% directionality. 
%
%
% ## Notes:
%
% * This method is equivalent to gcdir
%
%
% ## Reference:
%
% [1] Gomez Herrero G. 2010, Brain Connectivity Analysis with EEG, PhD
%     Thesis, Tampere University of Technology, Finland. 
%
%
%
% See also: pte, gc, gcdir, pmi, pmidir

% Documentation: class_var_abstract_var.txt
% Description: PTE-based dir. index

import var.abstract_var;

if nargin < 5, lag = []; end
if nargin < 4, Theta = []; end
if nargin < 3,
    throw(abstract_spt.InvalidInput(...
        'At least 3 input arguments are expected'));
end

x = pte(obj, Gamma, Phi, Theta, lag);
y = pte(obj, Phi, Gamma, Theta, lag);

diVal = (x-y)/(x+y);


end