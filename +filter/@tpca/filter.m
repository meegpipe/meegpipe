function [x, obj] = filter(obj, x, varargin)

import misc.signal2hankel;
import misc.eta;


verbose = is_verbose(obj) && size(x,1) > 5;
verboseLabel = get_verbose_label(obj);


if verbose,
    fprintf( [verboseLabel, ...
        'tpca filtering of %d signals using delay embedding with %d lags...'], ...
        size(x,1), obj.Order);
end


tinit = tic;
pca = obj.PCA;
pca = set_verbose(pca, false);
dim = ceil(obj.Order/2);
for i = 1:size(x,1),
    d   = signal2hankel(x(i,:), obj.Order);
    pca = learn(pca, d);
    d   = proj(pca, d);
    if ~isempty(obj.PCFilter),
        d   = filtfilt(obj.PCFilter, d);
    end
    d   = bproj(pca, d);
    x(i,:) = d(dim,:);
    if verbose,
        eta(tinit, size(x, 1), i, 'remaintime', false);
    end
end

if verbose, fprintf('\n\n'); end

end