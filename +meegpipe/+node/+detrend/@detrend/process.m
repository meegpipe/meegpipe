function [data, dataNew] = process(obj, data, varargin)


import misc.eta;
import goo.globals;

dataNew = [];

verbose         = is_verbose(obj);
verboseLabel    = get_verbose_label(obj);


if verbose,
    
    fprintf([verboseLabel, 'Detrending ''%s''...\n\n'], get_name(data));
    
end

% Configuration options
chopSel         = get_config(obj, 'ChopSelector');
expandBoundary  = get_config(obj, 'ExpandBoundary');
decimation      = get_config(obj, 'Decimation');
polyOrder       = get_config(obj, 'PolyOrder');


%% Find chop boundaries
if ~isempty(chopSel),
    chopEvents = select(chopSel, get_event(data));
    
    if ~isempty(chopEvents),
        evSample = get(chopEvents, 'Sample');
        evDur    = get(chopEvents, 'Duration');
    end
else
    evSample = 1;
    evDur    = size(data,2);
end

tinit = tic;
for segItr = 1:numel(evSample)
    
    if verbose,
        
        fprintf( [verboseLabel ...
            'Detrending epoch %d/%d...'], ...
            segItr, numel(evSample));
        
    end
    
    first = evSample(segItr);
    last  = evSample(segItr)+evDur(segItr)-1;
    
    segLength = last - first + 1;
    
    % Expand boundaries?
    if expandBoundary,
        
        leftExpand = ceil(0.02*segLength);
        
        if first < leftExpand,
            leftExpand = first - 1;
        end
        
        rightExpand = ceil(0.02*segLength);
        
        if last + rightExpand > size(data,2),
            rightExpand = size(data,2)-last;
        end
        
    else
        
        leftExpand  = 0;
        rightExpand = 0;
        
    end
 
    select(data, [], first-leftExpand:last+rightExpand);
    
    for i = 1:nb_dim(data)
        
        if data.BadChan(i), continue; end
        
        M       = data(i, 1:end);
        
        x = 1:nb_pnt(data);
        if decimation > 1,
            dx      = x(1:decimation:end);  %#ok<*NASGU>
            dM      = decimate(M, decimation);
        else
            dx      = x;
            dM      = M;
        end
        
        % Run polyfit with stdout capture
        thisOrder = polyOrder;
        
        % Need to pre-declare mu or the code below breaks in some MATLAB
        % versions (e.g. R2011a)
        mu = [];
        T = evalc('[p, ~, mu] = polyfit(dx(:), dM(:), thisOrder);');
        
        % If ill conditioning warning, redo for lower orders
        while ~isempty(T) && ~isempty(strfind(T, 'badly conditioned')) && ...
                thisOrder > 5,
            
            thisOrder = thisOrder - 1;
            T = evalc('[p, ~, mu] = polyfit(dx(:), dM(:), thisOrder);');
            
        end
        if ~isempty(T), disp(T); end
        
        M = M - polyval(p, (x-mu(1))/mu(2));
   
        data(i, leftExpand+1:end-rightExpand) = ...
            M(leftExpand+1:end-rightExpand);
        
        
        if verbose,
            eta(tinit, nb_dim(data), i, 'remaintime', false);
        end
        
    end   
   
    
    restore_selection(data);
    
    if verbose,
        fprintf('\n\n');
    end
    
end

if verbose,
    fprintf('\n\n');
    clear +misc/eta.m;
end

end