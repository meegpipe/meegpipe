function rankValue = compute_rank(obj, sptObj, data, sr, ~, ~, raw, varargin)

import misc.peakdet;
import misc.eta;
import goo.pkgisa;


verbose         = is_verbose(obj);
verboseLabel    = get_verbose_label(obj);


chanSet     = get_config(obj, 'ChannelSet');
aggregator  = get_config(obj, 'ChannelAggregator');
filtObj     = get_config(obj, 'Filter');

% Indices of the matching channel labels
sensLabels = labels(sensors(raw));
if isempty(chanSet),
    matches = true(size(sensLabels));
else
    
    matches = false(size(sensLabels));
    for i = 1:numel(sensLabels)
        for j = 1:numel(chanSet)
            if ~isempty(regexp(sensLabels{i}, chanSet{j}, 'once')),
                matches(i) = true;
                break;
            end
        end
    end
end

% Take into account bad channels, if we are dealing with a physioset
if isa(data, 'physioset.physioset'),
    matches = matches & ~is_bad_channel(raw);
end


rankValue = zeros(1, size(data,1));
A = bprojmat(sptObj);

if isa(raw, 'physioset.physioset')
    select(raw, matches);
end

if ~isempty(filtObj),
    if isa(filtObj, 'function_handle'),
        filtObj = filtObj(sr);
    end
    if isa(raw, 'pset.mmappset'),
        filtData = copy(raw);
    else
        filtData = raw;
    end
    filter(filtObj, filtData);
else
    filtData = raw;
end

tinit = tic;
if verbose,
    fprintf([verboseLabel 'Computing explained variance criterion ...']);
end

filtDataVar = var(filtData, 0, 2);

for sigIter = 1:size(data,1)
    
    % Do not assume that the rows of data are uncorrelated, although they
    % usually will be!
    thisSignal  = A(matches, sigIter)*data(sigIter, :);
    
    rankValue(sigIter) = aggregator(var(thisSignal, 0 , 2)./filtDataVar);
    
    if verbose,
        eta(tinit, size(data, 1), sigIter, 'remaintime', false);
    end
    
end

if isa(raw, 'physioset.physioset')
    restore_selection(raw);
end

if verbose,
    fprintf('\n\n');
end


end