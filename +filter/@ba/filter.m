function [x, obj] = filter(obj, x, varargin)

import misc.eta;

verbose         = is_verbose(obj) && size(x,1) > 10;
verboseLabel 	= get_verbose_label(obj);


if verbose,
    fprintf( [verboseLabel, 'Filtering %d signals...'], size(x,1));
end

if verbose,
    tinit = tic;
    clear +misc/eta;
end

if obj.CorrectDelay,
    delay = get_filter_delay(obj);
else
    delay = 0;
end

if 5*delay > size(x, 2),
    error(['Signal length (%d) must be at least 5 times as long as the ' ...
        'filter (%d)'], size(x,2), delay);
end

if isnan(obj.NbChansPerChunk),
    if isa(x, 'pset.mmappset'),
        precision = x.Precision;
    else
        precision = class(x);
    end
    nbBytes = misc.sizeof(precision);
    maxChunk = meegpipe.get_config('pset', 'largest_memory_chunk');
    maxChansPerChunk = max(1, floor(maxChunk/(size(x, 2)*nbBytes)));
else
    maxChansPerChunk = obj.NbChansPerChunk;
end

for i = 1:maxChansPerChunk:size(x,1),
    chansIdx = i:min(size(x,1), i+maxChansPerChunk-1);
    thisChunk = x(chansIdx, :);
    
    thisX = [fliplr(thisChunk(:, 1:(2*delay))) thisChunk];
    
    y = filter(obj.B, obj.A, thisX')';
    if numel(obj.A) > 1,
        x(chansIdx,:) = y(:, 2*delay+1:end);
    else
        x(chansIdx, 1:end-delay) = y(:, (3*delay+1):end);
        x(chansIdx, end-delay+1:end) = ...
            fliplr(y(:, (end-delay+1):end));
    end
    
    if verbose,
        eta(tinit, size(x,1), i, 'remaintime', false);
    end
    
end

if verbose,
    eta(tinit, size(x, 1), size(x, 1), 'remaintime', false);
    fprintf('\n\n');
    clear +misc/eta;
end

end