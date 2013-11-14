function A = learn_coeffs(obj, data)
% LEARN_COEFSS - Learns VAR coefficients
%
% A = learn_coeffs(obj, data)
%
% Where
%
% DATA is a D x K matrix containing K observations of a D-dimensional
% process.
%
% A is a D x (D x P) matrix containing the coefficients of the best fitting
% VAR model of order P.
%
%
% See also: var.estimator

% Description: Learns VAR coefficients
% Documentation: class_var_arfit.txt

import external.arfit.arfit;


[~, A] = arfit(data', obj.MinOrder, obj.MaxOrder, ...
            obj.OrderCriterion, 'zero', obj.ForceMin);



end