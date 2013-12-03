function [d, obj] = filter(obj, x, varargin)

import misc.signal2hankel;
import misc.eta;


verbose = is_verbose(obj) && size(x,1) > 5;
verboseLabel = get_verbose_label(obj);

origVerboseLabel = goo.globals.get.VerboseLabel;
goo.globals.set('VerboseLabel', verboseLabel);

pca = obj.PCA;
pca = set_verbose(pca, verbose);

pca = learn(pca, x);
d   = proj(pca, x);
if ~isempty(obj.PCFilter),
    if verbose,
        fprintf([verboseLabel 'Filtering PCs using %s ...\n\n'], ...
            class(obj.PCFilter));
    end
    d   = filtfilt(obj.PCFilter, d);
end
d   = bproj(pca, d);

goo.globals.set('VerboseLabel', origVerboseLabel);

end