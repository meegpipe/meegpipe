function res = residuals(obj, data)

import external.arfit.arres;

if nargin < 2 || isempty(data),
    res = obj.Residuals;
    return;
end

res = arres(zeros(size(obj.Coeffs,1),1), obj.Coeffs, data')';
res = [zeros(size(res,1), order(obj)) res];

end