function [W, A, selection, obj] = learn_basis(obj, data, varargin)

import efica.efica; 

randSeed = get_seed(obj);
warning('off', 'MATLAB:RandStream:ActivatingLegacyGenerators');
rand('state',  randSeed); %#ok<RAND>
randn('state', randSeed); %#ok<RAND>
warning('on', 'MATLAB:RandStream:ActivatingLegacyGenerators');
obj = set_seed(obj, randSeed);

W = efica(data);
A = pinv(W);
selection = 1:size(W,1);

end