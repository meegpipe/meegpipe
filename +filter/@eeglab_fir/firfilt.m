function data = firfilt(data, b, nFrames, verbose, verboseLabel)

import filter.eeglab_fir;

% Taken from EEGLAB's firfilt


if nargin < 2
    error('Not enough input arguments.');
end
if nargin < 3 || isempty(nFrames)
    nFrames = 1000;
end

% Filter's group delay
if mod(length(b), 2) ~= 1
    error('Filter order is not even.');
end
groupDelay = (length(b) - 1) / 2;

% Find data discontinuities
evBndry = get_event(data);
if ~isempty(evBndry),
    evBndry = select(evBndry, 'Type', 'boundary');
end
if ~isempty(evBndry),
    evBndry = eeglab(evBndry);
end
dcArray = [eeglab_fir.findboundaries(evBndry) size(data,2) + 1];

if verbose,
    if isa(data, 'goo.named_object') || isa(data, 'goo.abstract_named_object'),
        name = get_name(data);
    else
        name = '';
    end
    fprintf([verboseLabel ' Filtering %s in %d chunks ...'], name, ...
        (length(dcArray) - 1));
end
for iDc = 1:(length(dcArray) - 1)
    
    % Pad beginning of data with DC constant and get initial conditions
    ziDataDur = min(groupDelay, dcArray(iDc + 1) - dcArray(iDc));
    [~, zi] = filter(b, 1, double([data(:, ones(1, groupDelay) * dcArray(iDc)) ...
        data(:, dcArray(iDc):(dcArray(iDc) + ziDataDur - 1))]), [], 2);
    
    blockArray = [(dcArray(iDc) + groupDelay):nFrames:(dcArray(iDc + 1) - 1) dcArray(iDc + 1)];
    if verbose,
        tinit = tic;
    end
    for iBlock = 1:(length(blockArray) - 1)
        
        % Filter the data
        [data(:, (blockArray(iBlock) - groupDelay):(blockArray(iBlock + 1) - groupDelay - 1)), zi] = ...
            filter(b, 1, double(data(:, blockArray(iBlock):(blockArray(iBlock + 1) - 1))), zi, 2);
        
        if verbose,
            misc.eta(tinit, (length(blockArray) - 1), iBlock);
        end
    end
    if verbose,
        clear +misc/eta;
    end
    
    % Pad end of data with DC constant
    temp = filter(b, 1, double(data(:, ones(1, groupDelay) * (dcArray(iDc + 1) - 1))), zi, 2);
    data(:, (dcArray(iDc + 1) - ziDataDur):(dcArray(iDc + 1) - 1)) = ...
        temp(:, (end - ziDataDur + 1):end);
end

if verbose, fprintf('\n\n'); end

end
