function [evBad, rejIdx, samplIdx] = find_bad_epochs(obj, data, ev, rep)

import meegpipe.node.bad_epochs.criterion.rank.rank;

if nargin < 4, rep = []; end

verbose         = is_verbose(obj);
verboseLabel    = get_verbose_label(obj);


if verbose,
    
    fprintf([verboseLabel 'Rejecting epochs from %s...\n\n'], ...
        get_name(data));
    
end

% Configuration options
minRank = get_config(obj, 'Min');
maxRank = get_config(obj, 'Max');
MADs    = get_config(obj, 'MADs');
perc    = get_config(obj, 'Percentile');
minC    = get_config(obj, 'MinCard');
maxC    = get_config(obj, 'MaxCard');

[rankIndex, ev2] = compute_rank(obj, data, ev);

ev = ev2;
selected  = false(1, size(data,1));

if isa(minRank, 'function_handle'),
    minRank = minRank(rankIndex);
end

if isa(maxRank, 'function_handle'),
    maxRank = maxRank(rankIndex);
end

% Min/Max criterion
if ~isempty(maxRank),
    selected(rankIndex > maxRank) = true;
end
if ~isempty(minRank),
    selected(rankIndex < minRank) = true;
end

% Percentile criterion
if ~isempty(perc),
    th = prctile(rankIndex, perc);
    selected(rankIndex < th(1) | rankIndex > th(2)) = true;
end

% MADs
if ~isempty(MADs),
    
    if numel(MADs) == 1,
        MADs = repmat(MADs, 1, 2);
    end
    
    rankMAD = mad(rankIndex);
    rankMed = median(rankIndex);
    selected(rankIndex < rankMed - MADs(1)*rankMAD | ...
        rankIndex > rankMed + MADs(2)*rankMAD) = true;
end

% Minimum and maximum cardinality of the set of selected channels
rI2 = abs(rankIndex - median(rankIndex));
[~, order] = sort(rI2, 'descend');

if minC > size(data,1),
    selected(1:end) = true;
elseif minC > 0 ,    
    selected(order(1:minC)) = true;
end
if maxC < numel(selected)
    selected(order(maxC+1:end)) =  false;
end

if verbose,
    fprintf([verboseLabel 'Selected %d epochs using %s\n\n'], ...
        sum(selected), class(obj));
end

evBad = ev(selected);

rejIdx = find(selected);

[~, ~, samplIdx] = epoch_get(data, evBad);

if ~isempty(rep),
   rank.generate_rank_report(rep, rankIndex, rejIdx, minRank, maxRank);
end

end

