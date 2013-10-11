function [W, A, selection, obj] = learn_basis(obj, data, varargin)


import runica.runica;

if is_verbose(obj),
    verbose = 'on';
else
    verbose = 'off';
end

% configuration options
extended = get_config(obj, 'Extended');

randSeed = get_seed(obj);


warning('off', 'MATLAB:RandStream:ActivatingLegacyGenerators');

[a,b] = runica(data, ...
    'verbose',      verbose, ...
    'randstate',    randSeed, ...
    'extended',     extended);

warning('on', 'MATLAB:RandStream:ActivatingLegacyGenerators');

obj = set_seed(obj, randSeed);

W     = a*b;
A     = pinv(W);

selection = 1:size(W,1);

end