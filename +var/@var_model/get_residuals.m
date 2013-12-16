function res = get_residuals(obj, data)

import external.arfit.arres;

data = transpose(data);

res = arres(zeros(size(obj.Coeffs,1),1), obj.Coeffs, data)';

res = transpose(res);

% Necessary if data is a pset.mmappset object. Otherwise, harmless.
transpose(data);

res = [zeros(size(res,1), order(obj)) res];

end