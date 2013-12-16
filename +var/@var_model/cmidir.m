function diVal = cmidir(obj, Gamma, Phi, lag)
% CMIDIR - CMI-based directionality index
%
% y = cmidir(obj, gamma, phi, lag)
%
% Where
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
% See also: pte, pmi, gc, abstract_var

% Documentation: class_var_abstract_var.txt
% Description: CMI-based dir. index

import var.abstract_var;

if nargin < 3,
    throw(abstract_var.InvalidInput(...
        'At least 3 input arguments are expected'));
end

if nargin < 4 || isempty(lag),
    lags = 1;
end


x = cmi(obj, Gamma, Phi, lag);
y = cmi(obj, Phi, Gamma, lag);

diVal = (x-y)/(x+y);


end