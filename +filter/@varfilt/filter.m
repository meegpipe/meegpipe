function [data, obj] = filter(obj, data, varargin)
% FILTER - Filter method for varfilt objects

import misc.eta;
import misc.dimtype_str;

verbose      = is_verbose(obj);
verboseLabel = get_verbose_label(obj);

tinit = tic;
if verbose,
    if isa(data, 'pset.mmappset'),
        name = get_name(data);
    else
        name = dimtype_str(data);
    end
    fprintf([verboseLabel 'VAR-filtering %s ...'], name);
end
if obj.ForceAR
    for i = 1:size(data,1)
        varObj = learn(obj.VAR, data(i,:));
        data(i, :) = residuals(varObj, data(i, :));
        if verbose
            eta(tinit, size(data,1), i);
        end
    end
else
    if verbose, fprintf('\n\n'); end
    varObj = learn(obj.VAR, data, 'verbose', verbose);
    data   = residuals(varObj, data);
end

end