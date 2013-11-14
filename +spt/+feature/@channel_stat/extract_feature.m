function featVal = extract_feature(obj, sptObj, tSeries, varargin)

import misc.peakdet;
import misc.eta;
import goo.pkgisa;


verbose         = is_verbose(obj);
verboseLabel    = get_verbose_label(obj);

featVal = zeros(1, size(tSeries,1));

A = bprojmat(sptObj);

tinit = tic;
if verbose,
    fprintf([verboseLabel 'Computing explained variance ...']);
end


for sigIter = 1:size(tSeries, 1)
    
    % Do not assume that the rows of tSeries are uncorrelated!
    if isa(tSeries, 'pset.mmappset'),
        select(tSeries, sigIter);
        thisBP = A(:, sigIter)*tSeries;
        select(obj.TargetSelector, thisBP);
    else
        thisBP  = A(:, sigIter)*tSeries(sigIter, :);
    end
    
    chanStat = obj.ChannelStat(thisBP);
    featVal(sigIter) = obj.AggregatingStat(chanStat);
    
    if isa(tSeries, 'pset.mmappset'),
        restore_selection(tSeries);
    end
    
    if verbose,
        eta(tinit, size(tSeries, 1), sigIter, 'remaintime', false);
    end
    
end

if verbose,
    fprintf('\n\n');
end


end