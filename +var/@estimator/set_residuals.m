function obj = set_residuals(obj, value)

obj.Residuals = value;
obj.ResCov = cov(value');

end