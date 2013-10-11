function [W, A, selection, obj] = learn_basis(obj, data, varargin)


import multicombi.multicombi;
import efica.efica;

arOrder = get_config(obj, 'AROrder');

% Set the random number generator state

randSeed = get_seed(obj);

warning('off', 'MATLAB:RandStream:ActivatingLegacyGenerators');
rand('state',  randSeed); %#ok<RAND>
randn('state', randSeed); %#ok<RAND>
warning('on', 'MATLAB:RandStream:ActivatingLegacyGenerators');


obj = set_seed(obj, randSeed);

try
    W = multicombi(data, arOrder, false);
catch ME
    if strcmp(ME.identifier, 'MATLAB:nearlySingularMatrix'),
        warning('learn_basis:Singular', ...
            ['multicombi failed due to a close to singular matrix ' ...
            'inversion: falling back to efica']);
        W = efica(data);
    else
        rethrow(ME);
    end
end

if isempty(W),
    W = randn(size(data,1));
    selection = [];
elseif size(W,1) < size(data,1),
    selection = 1:size(W,1);
    W = [W;randn(size(data,1)-size(W,1), size(data,2))];
else
    selection = 1:size(W,1);
end

A = pinv(W);

end