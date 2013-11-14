classdef algorithm
   % ALGORITHM - VAR estimation algorithm
   %
   % 
   % See also: var.estimator
   
   % Description: Interface for VAR estimation algorithms
   % Documentation: ifc_var_algorithm.txt
   
   methods (Abstract)
      A = learn_coeffs(obj, data); 
   end
    
end