function rankValue = compute_rank(obj, ~, data,  sr, ev, varargin)

import misc.eta;
import misc.epoch_get;
import misc.epoch_align;



if nargin < 5 || isempty(data) || isempty(sr),
    error('At least 5 input arguments are expected');
end

if isempty(ev),
    rankValue = zeros(1, size(data,1));
    return;
end

% Configuration options
evSel       = get_config(obj, 'EventSelector');
latRange    = get_config(obj, 'LatencyRange');

if ~isempty(evSel),
    ev = select(evSel, ev);
end

if ~isempty(latRange),
    ev = set(ev, 'Offset', sr*latRange(1));
    ev = set(ev, 'Duration', sr*diff(latRange));
end

if isempty(ev),
    error('No events!');
end

verboseLabel = get_verbose_label(obj);

if is_verbose(obj),
    fprintf([verboseLabel 'Computing terp rank for %d time series...'], ...
        size(data,1));
end

rankValue = zeros(1, size(data,1));

if is_verbose(obj),
    tinit = tic;
    clear +misc/eta;
end
for tsIter = 1:size(data,1)    
   
    x = data(tsIter, :);
    x = squeeze(epoch_get(x, ev));
    %[~, trialCorr] = epoch_align(x', maxLag, false);
    
    count = 0;
    trialCorr = nan((size(x,2)^2-size(x,2))/2,1);
    for i = 1:size(x,2),
        for j = i+1:size(x,2)
            count = count + 1;
            trialCorr(count) = x(:,i)'*x(:,j);
        end
    end

    rankValue(tsIter) = median(abs(trialCorr));
    
    if is_verbose(obj),
        eta(tinit, size(data,1), tsIter);
    end
    
end

if is_verbose(obj),
    fprintf('[done]\n\n');
end

rankValue = rankValue-min(rankValue);
rankValue = rankValue./max(rankValue);


end