function obj = learn_basis(obj, data, varargin)


import runica.runica;

if is_verbose(obj),
    verbose = 'on';
else
    verbose = 'off';
end

randSeed = get_seed(obj);
warning('off', 'MATLAB:RandStream:ActivatingLegacyGenerators');

[a,b] = runica(data(:,:), ...
    'verbose',      verbose, ...
    'randstate',    randSeed, ...
    'extended',     obj.Extended);

warning('on', 'MATLAB:RandStream:ActivatingLegacyGenerators');

obj = set_seed(obj, randSeed);

W     = a*b;
A     = pinv(W);

selection = 1:size(W,1);

obj.W = W;
obj.A = A;
obj.ComponentSelection = selection;
obj.DimSelection       = 1:size(data,1);

end