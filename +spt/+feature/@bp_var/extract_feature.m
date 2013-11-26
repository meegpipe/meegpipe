function featVal = extract_feature(obj, sptObj, tSeries, raw, varargin)

import misc.peakdet;
import misc.eta;
import goo.pkgisa;


verbose         = is_verbose(obj);
verboseLabel    = get_verbose_label(obj);

goo.globals.set('Verbose', false);


% The full back-projection matrix
A = bprojmat(sptObj, true);

if verbose,
    fprintf([verboseLabel 'Computing raw data variance ...']);
end
select(obj.DataSelector, raw);
hasSelection = has_pnt_selection(raw);
rawDataVar = var(raw, [], 2);
A = A(dim_selection(raw), :);
restore_selection(raw);
if verbose,
    fprintf('[done]\n\n');
end

if verbose,
    fprintf([verboseLabel 'Computing channel statistics ...']);
end

featVal = nan(size(tSeries, 1), 1);
if hasSelection,
    error('Not implemented');
else
    for i = 1:size(tSeries,1)
        featVal(i) = obj.AggregatingStat(A(:,i).^2, rawDataVar);
    end
end

if verbose,
    fprintf('\n\n');
end

goo.globals.set('Verbose', verbose);

end