function rankValue = compute_rank(obj, ~, data, sr, varargin)

import misc.peakdet;
import misc.eta;


verbose         = is_verbose(obj);
verboseLabel    = get_verbose_label(obj);

if verbose,
    fprintf([verboseLabel 'ACF computation...']);
end

nbPeriods   = get_config(obj, 'NbPeriods');
period      = get_config(obj, 'Period');
periodMarg  = get_config(obj, 'PeriodMargin');
delta       = get_config(obj, 'Delta');

lag         = round(period*sr);
lagMargin   = ceil(periodMarg*sr);
maxLag      = min(size(data,2), nbPeriods*lag+lagMargin);
signalLags  = lag + (-lagMargin:lagMargin);

tinit = tic;
rankValue = zeros(size(data,1),1);

for sigIter = 1:size(data, 1)
    
    acf = xcorr(data(sigIter,:), maxLag, 'coeff');
    acf = acf((maxLag+1):end);
    maxtab = peakdet(acf, delta);
    
    if ~isempty(maxtab)
        maxtab = maxtab(ismember(maxtab(:,1), signalLags),:);
    end
    
    if ~isempty(maxtab) && any(maxtab(:,2)>0),
        rankValue(sigIter) = max(maxtab(:,2));
    end
    
    if verbose,
        eta(tinit, size(data, 1), sigIter, 'remaintime', false);
    end
    
end

if verbose, fprintf('\n\n'); end

end