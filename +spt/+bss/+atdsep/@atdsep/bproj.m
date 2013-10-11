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

% Documentation: class_atdsep.txt
% Description: Backward spatial projection

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

if verbose,
    fprintf(...
        [verboseLabel '%s spatial back-projection...'], ...
        class(obj));
end

A = bprojmat(obj);

y = nan(size(data));
for i = 1:size(data,2)

    thisA = A(:, :, i); 
    y(:,i) = thisA(:, idx)*data(:,i);

end


if verbose,
    fprintf('[done]\n\n');
end

if obj.EmbedDim < 2,
    return;
end

if verbose,
    fprintf(...
        [verboseLabel  'Inverting delay-embedding...']);
end
ndims = round(size(y,1)/obj.EmbedDim);

if (ndims-(size(y,1)/obj.EmbedDim)) > eps,
    error('bproject:invalidDim', ...
        'The input data does not have the expected dimensionality.');
end

if isa(y, 'pset.pset'),
    y2 = pset.pset.nan(ndims, obj.EmbedDim+size(data,2)-1);
else
    y2 = nan(ndims, obj.EmbedDim+size(data,2)-1);
end

for i = 1:ndims
    tmp = subset(y, i:ndims:size(y,1));
    y2(i,:) = hankel2signal(tmp(:,:));
end

y = y2;
if verbose,
    fprintf('[done]\n\n');
end
