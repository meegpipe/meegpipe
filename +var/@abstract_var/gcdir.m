function diVal = gcdir(obj, Gamma, Phi, Theta, lag)
% GCDIR - GC-based directionality index
%
% y = gcdir(obj, gamma, phi, theta, lags)
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
% to which the PTE should be partialized
%
% LAGS is a numeric array with the lags to use for building the past of the
% time series. By default, LAGS=1
%
% Y is the directionality index, which is a number in the range [-1 1]. If
% Y < 0 then the information flow is the opposite direction to the one
% provided. Otherwise, the information flow agrees to the provided
% directionality. 
%
% ## Notes:
%   
%   * This method is equivalent to method ptedir()
%
%
% See also: gc, ptedir, pmidir, abstract_var


% Documentation: class_var_abstract_var.txt
% Description: GC-based dir. index

import var.abstract_var;

if nargin < 5, lag = []; end
if nargin < 4, Theta = []; end
if nargin < 3,
    throw(abstract_spt.InvalidInput(...
        'At least 3 input arguments are expected'));
end

x = gc(obj, Gamma, Phi, Theta, lag);
y = gc(obj, Phi, Gamma, Theta, lag);

diVal = (x-y)/(x+y);


end