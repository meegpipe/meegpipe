function data = get_observations(obj, innovations)
% GET_OBSERVATIONS - Generate VAR model observations (measurements)

import external.arfit.arsim;
import external.randint.rand_int;

innovations = transpose(innovations);

data = arsim(...
    zeros(obj.NbDims,1), ...      % The mean vector, always zeros
    obj.Coeffs, ...               % The model coefficients
    obj.ResCov, ...               % The residuals (noise) covariance
    size(innovations, 2), ...     % Number of samples to generate
    max(100, ceil(.05*size(innovations,2))), ...
    innovations); 

% Necessary if innovations is a pset.mmappset object
transpose(innovations);

if any(abs(obj.DataMean) > eps),
    for i = 1:size(data, 1),
        data(i,:) = data(i,:) + obj.DataMean(i);
    end
end

end