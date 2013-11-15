function [selected, featVal] = select(obj, objSpt, tSeries, varargin)
% SELECT - Selects criterion matching components

import exceptions.InvalidObject;

verbose         = is_verbose(obj);
verboseLabel    = get_verbose_label(obj);

if isempty(obj.Feature),
    throw(InvalidObject('Property ''Feature'' needs to be specified'));
end

featVal = extract_feature(obj.Feature, objSpt, tSeries, varargin{:});

selected = false(1,size(tSeries,1));


if isa(obj.Max, 'function_handle'),
    maxTh = obj.Max(featVal);
else
    maxTh = obj.Max;
end
selected(featVal > maxTh) = true;

if isa(obj.Min, 'function_handle'),
    minTh = obj.Min(featVal);
else
    minTh = obj.Min;
end
selected(featVal < minTh) = true;

[~, idx] = sort(featVal, 'descend');

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

if verbose,
    fprintf([verboseLabel 'Selected %d components using criterion'  ...
        '%s on feature %s\n\n'], ...
        sum(selected), class(obj), class(obj.Feature));
end


end

