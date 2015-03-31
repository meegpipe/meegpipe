function obj = assign_values(obj, otherObj, verbose)
% ASSIGN_VALUES - Assign values from another pointset

import misc.eta;

if nargin < 3 || isempty(verbose),
    verbose = false;
end

if ~isa(otherObj, 'pset.pset'),
    error('Second argument must be a pset.pset object');
end

if ~all(size(obj) == size(otherObj)),
    error('Dimensions of the two pset objects do not match');
end

if verbose,
    tinit = tic;
end
for i = 1:otherObj.NbChunks
    [index, dataOtherObj] = get_chunk(otherObj, i);
    if otherObj.Transposed,        
        s.subs = {index, 1:nb_dim(otherObj)};        
    else
        s.subs = {1:nb_dim(otherObj), index};        
    end
    s.type = '()';
    obj = subsasgn(obj, s, dataOtherObj);
    if verbose,
        eta(tinit, obj.NbChunks, i, 'remaintime', false);
    end
end

end