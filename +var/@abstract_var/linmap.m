function obj = linmap(obj, A)
% LINMAP - Linear map
%
% newObj = linmap(obj, A)
%
% Where
%
% OBJ is a var.var object of dimensionality K
%
% NEWOBJ is the VAR model (a var.var object) of dimensinality L that 
% results from linearly mapping the observation of model OBJ using 
% LxK matrix A. 
%
% See also: var

% Description: Linear mapping
% Documentation: class_var_abstract_var.txt


oldCoeffs = get_coeffs(obj);
obj = set_coeffs(A*oldCoeffs*pinv(A));

oldInn    = get_inn(obj);
if ~isempty(oldInn),
    obj = set_inn(A*oldInn);
end

icov = get_icov(obj);
obj = set_icov(A*icov*pinv(A));

noise = get_noise(obj);
if ~isempty(noise),
    obj = set_noise(A*noise);
end

ncov = get_ncov(obj);
if ~isempty(ncov),
    obj = set_ncov(A*ncov*pinv(A));
end

end