function [selected, featVal] = select(obj, objSpt, tSeries, varargin)
% SELECT - Selects criterion matching components

import exceptions.InvalidObject;

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

selected = false(1,size(tSeries,1));

maxTh = nan(1, numel(obj.Feature));
for featItr = 1:numel(obj.Feature),
    if isa(obj.Max{featItr}, 'function_handle'),
        maxTh(featItr) = obj.Max{featItr}(featVal(:, featItr));
    else
        maxTh(featItr) = obj.Max{featItr};
    end
    selected(featVal(:, featItr) > maxTh(featItr)) = true;
end

minTh = nan(1, numel(obj.Feature));
for featItr = 1:numel(obj.Feature),
    if isa(obj.Min{featItr}, 'function_handle'),
        minTh(featItr) = obj.Min{featItr}(featVal(:, featItr));
    else
        minTh(featItr) = obj.Min{featItr};
    end
    selected(featVal(:, featItr) < minTh(featItr)) = true;
end

% Sort components by their distance to the hypercube delimited by the
% various thresholds
maxTh = repmat(maxTh, size(tSeries, 1), 1);
minTh = repmat(minTh, size(tSeries, 1), 1);
[~, idx] = sort(max(max(featVal-maxTh, minTh-featVal), [], 2), 'descend');

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
    fprintf([verboseLabel 'Selected %d components using criterion'  ...
        '%s on feature %s\n\n'], ...
        sum(selected), class(obj), class(obj.Feature));
end


end

