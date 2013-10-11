function y = bproj(obj, data)
% bproj - Backward spatial projection
%
%
% y = bproj(obj, x)
%
% Where
%
% X is a numeric data matrix or a pointset container
%
% Y is the result of applying the spatial transformation described by OBJ
% on its input data.
%
%
% See also: spt.proj


import misc.subset;
import misc.hankel2signal;
import spt.generic.generic;

if isempty(obj.W),
    error('You need to learn() first!');
end

idx  = selection(obj);

if isempty(idx),
    y = [];
    return;
end

verbose      = is_verbose(obj);
verboseLabel = get_verbose_label(obj);
embedDim = get_config(obj, 'EmbedDim');

if verbose,
    fprintf(...
        [verboseLabel '%s spatial back-projection...'], ...
        class(obj));
end

y = obj.A(:, idx)*data;

if verbose,
    fprintf('[done]\n\n');
end

if embedDim < 2,
    return;
end

if verbose,
    fprintf(...
        [verboseLabel  'Inverting delay-embedding...']);
end
ndims = round(size(y,1)/embedDim);

if (ndims-(size(y,1)/embedDim)) > eps,
    error('bproject:invalidDim', ...
        'The input data does not have the expected dimensionality.');
end

if isa(y, 'pset.pset'),
    y2 = pset.pset.nan(ndims, embedDim+size(data,2)-1);
else
    y2 = nan(ndims, embedDim+size(data,2)-1);
end

for i = 1:ndims
    tmp = subset(y, i:ndims:size(y,1));
    y2(i,:) = hankel2signal(tmp(:,:));
end

y = y2;
if verbose,
    fprintf('[done]\n\n');
end
