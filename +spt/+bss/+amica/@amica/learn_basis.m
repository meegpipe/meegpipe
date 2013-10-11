function [W, A, selection, obj] = learn_basis(obj, data, varargin)


import amica.amica;


% Set the random number generator state
randSeed = get_seed(obj);
rand('state', randSeed); %#ok<RAND>
randn('state', randSeed); %#ok<RAND>

% Configuration options
nbMixtures = get_config(obj, 'NbMixtures');
maxIter    = get_config(obj, 'MaxIter');
updateRho  = get_config(obj, 'UpdateRho');
minLL      = get_config(obj, 'MinLL');
iterWin    = get_config(obj, 'IterWin');
doNewton   = get_config(obj, 'DoNewton');

W = amica(data, 1, ...
    nbMixtures, ...
    maxIter, ...
    updateRho, ...
    minLL, ...
    iterWin, ...
    doNewton, ...
    true, ...   % Remove mean?
    false);

A = pinv(W);
selection = 1:size(W,1);

obj = set_seed(obj, randSeed);



end