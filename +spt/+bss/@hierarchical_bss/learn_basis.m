function obj = learn_basis(obj, data, varargin)

% Set the random number generator state
randSeed = get_seed(obj);
warning('off', 'MATLAB:RandStream:ActivatingLegacyGenerators');
rand('state',  randSeed); %#ok<RAND>
randn('state', randSeed); %#ok<RAND>
warning('on', 'MATLAB:RandStream:ActivatingLegacyGenerators');
obj = set_seed(obj, randSeed);
obj.BSS = set_seed(obj.BSS, randSeed);

maxWindowLength = obj.MaxWindowLength;
if isa(maxWindowLength, 'function_handle'),
    maxWindowLength = maxWindowLength(data.SamplingRate);
end

nbSplits = ceil(log2(size(data,2)/maxWindowLength));

[obj.BSSwin, obj.] = learn_hierarchical_basis(obj, data);

end