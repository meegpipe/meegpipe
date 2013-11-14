function [selected, rankIndex] = select(obj, objSpt, data, sr, varargin)
% SELECT - Selects criterion matching components
%
% [selection, rankIndex] = select(obj, objSpt, data)
%
% Where
%
% OBJSPT is a spt.spt object describing the spatial transformation that
% maps the original measurement space to the component space. If not
% relevant or not available, provide an empty value.
%
% DATA are the temporal activations of the spatial components (observations
% are columnwise).
%
% See also: spt.criterion.trank, spt.criterion


if nargin < 4, sr = []; end
if nargin < 3, data = []; end

verbose         = is_verbose(obj);
verboseLabel    = get_verbose_label(obj);

% Configuration options
filtObj = get_config(obj, 'Filter');
minRank = get_config(obj, 'Min');
maxRank = get_config(obj, 'Max');
minCard = get_config(obj, 'MinCard');
maxCard = get_config(obj, 'MaxCard');

if ~isempty(objSpt) && ~isa(objSpt, 'spt.spt'),
    error('A spt.spt object was expected as second input argument');
end

if isa(minCard, 'function_handle'),
    minCard = minCard(size(data, 1));
end

if isa(maxCard, 'function_handle'),
    maxCard = maxCard(size(data, 1));
end

if ~isempty(filtObj),
    if isa(filtObj, 'function_handle'),
        filtObj = filtObj(sr);
        % Necessary in case of nested filters (i.e. BP filters) in order to
        % prevent the nested filters to produce status messages
        filtObj = set_verbose(filtObj, false);
    end
    filtObj = set_verbose(filtObj, verbose);
    data = filter(filtObj, data);
end

rankIndex = compute_rank(obj, objSpt, data, sr, varargin{:});

selected = false(1,size(data,1));

% Min/Max criterion
if ~isempty(maxRank),
    if isa(maxRank, 'function_handle'),
        maxRank = maxRank(rankIndex);
    end
    selected(rankIndex > maxRank) = true;
end
if ~isempty(minRank),
    if isa(minRank, 'function_handle'),
        minRank = minRank(rankIndex);
    end
    selected(rankIndex < minRank) = true;
end

% Let's not do this because it actually hides from the user the values of
% the raw ranks, which prevents him/her to use a suitable Min/Max threshold
% based on the rank values that are plotted in the HTML reports.
% rankIndex = rankIndex-min(rankIndex);
% rankIndex = rankIndex./max(rankIndex);
% rankIndex = rankIndex(:);


% Min/Max cardinality
[~, idx] = sort(rankIndex, 'descend');
if ~isempty(minCard) && minCard > 0,
    minCard = min(numel(idx), minCard);
    selected(idx(1:minCard)) = true;
end
if ~isempty(maxCard) && maxCard < Inf,
    selected(idx((maxCard+1):end)) = false;
end
if negated(obj),
    selected = ~selected;
end

if verbose,
    fprintf([verboseLabel 'Selected %d components using %s\n\n'], ...
        sum(selected), class(obj));
end


end

