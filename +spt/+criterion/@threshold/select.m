function [selected, featVal, rankIdx, obj] = select(obj, objSpt, tSeries, varargin)
% SELECT - Selects criterion matching components

import exceptions.InvalidObject;
import mperl.join;

verbose         = is_verbose(obj);
verboseLabel    = get_verbose_label(obj);

if isempty(obj.Feature),
    throw(InvalidObject('Property ''Feature'' needs to be specified'));
end

featVal = nan(size(tSeries,1), numel(obj.Feature));

for featItr = 1:numel(obj.Feature),
    thisFeat = extract_feature(obj.Feature{featItr}, objSpt, tSeries, ...
        varargin{:});
    featVal(:, featItr) = thisFeat(:);
end

selected = false(1, size(tSeries,1));

maxTh = nan(1, numel(obj.Feature));
maxSelected = false(numel(obj.Feature),size(tSeries,1));
for featItr = 1:numel(obj.Feature),
    if isa(obj.Max{featItr}, 'function_handle'),
        maxTh(featItr) = obj.Max{featItr}(featVal(:, featItr));
    else
        maxTh(featItr) = obj.Max{featItr};
    end
    maxSelected(featItr, featVal(:, featItr) > maxTh(featItr)) = true;
end
maxSelected = obj.SelectionAggregator(maxSelected);
selected(maxSelected) = true;

minTh = nan(1, numel(obj.Feature));
minSelected = false(numel(obj.Feature),size(tSeries,1));
for featItr = 1:numel(obj.Feature),
    if isa(obj.Min{featItr}, 'function_handle'),
        minTh(featItr) = obj.Min{featItr}(featVal(:, featItr));
    else
        minTh(featItr) = obj.Min{featItr};
    end
    minSelected(featItr, featVal(:, featItr) < minTh(featItr)) = true;
end
minSelected = obj.SelectionAggregator(minSelected);
selected(minSelected) = true;

% Sort components by their distance to the hypercube delimited by the
% various thresholds
shift = min(featVal);
featValNorm = featVal - repmat(shift, size(featVal, 1), 1);
scale = max(featValNorm);
featValNorm = featValNorm./repmat(scale, size(featVal, 1), 1);
if all(isinf(maxTh)) && all(isinf(minTh)),    
    rankIdx = mean(featValNorm, 2);
else
    maxThMat = repmat((maxTh-shift)./scale, size(tSeries, 1), 1);
    minThMat = repmat((minTh-shift)./scale, size(tSeries, 1), 1);
    
    distMax  = featValNorm-maxThMat;
    distMin  = minThMat-featValNorm; 
    
    % Use mean distance across features: more robust! 
    rankIdx  = mean(max(distMax, distMin), 2);
end

% Those components that are not outside the hypercube will be ranked lower
% that all components that are outside the hypercube. Otherwise you may end
% up with the case of no components being selected and MinCard>0 leading to
% the dangerous situation of removing a component that have a extreme value
% is just one of the features.
if any(selected),
    maxRankIdxInside = min(rankIdx(selected));
    rankIdx(~selected) = ...
        rankIdx(~selected).*maxRankIdxInside/max(rankIdx(~selected))-eps;
end

obj.RankIndex = rankIdx;
[~, idx] = sort(rankIdx, 'descend');

if isa(obj.MinCard, 'function_handle')
    minCard = obj.MinCard(featVal);
else
    minCard = obj.MinCard;
end

if minCard > 0,
    minCard = min(numel(idx), minCard);
    selected(idx(1:minCard)) = true;
end

if isa(obj.MaxCard, 'function_handle'),
    maxCard = obj.MaxCard(featVal);
else
    maxCard = obj.MaxCard;
end

if maxCard < Inf,
    selected(idx((maxCard+1):end)) = false;
end

if negated(obj),
    selected = ~selected;
end

obj.Selected = selected;
obj.FeatVals = featVal;

if verbose,
    featNames = cellfun(@(x) class(x), obj.Feature, 'UniformOutput', false);
    fprintf([verboseLabel 'Selected %d components using criterion '  ...
        'threshold on feature %s\n\n'], ...
        sum(selected), join(',', featNames));
end


end

