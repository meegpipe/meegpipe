function idx = find(obj, data, MADs, wl, ws, perc, minDur)
% FIND - Bad samples detection
%
% See also: physioset, bad_channels, bad_samples



import meegpipe.node.bad_samples.bad_samples;
import meegpipe.node.bad_samples.globals;
import misc.eta;

verbose = is_verbose(obj);
verboseLabel = get_verbose_label(obj);

if isa(wl, 'function_handle'),
    wl = wl(data.SamplingRate);
end

if isa(ws, 'function_handle'),
    ws = ws(data.SamplingRate, wl);
end

if isa(minDur, 'function_handle'),
    minDur = minDur(data.SamplingRate);
end

%% Preliminary sample rejection
if verbose,
    
    tinit = tic;
    fprintf([verboseLabel 'Preliminary sample rejection of %s...'], ...
        get_name(data));
    
end

% Central sample of each sliding window
winPos = 1:ws:nb_pnt(data);
if winPos(end) < nb_pnt(data), winPos(end) = nb_pnt(data); end

% Compute variance in sliding windows
topVar = nan(1, nb_pnt(data));
lowVar = nan(1, nb_pnt(data));
by100  = floor(numel(winPos)/100);

for i = 1:numel(winPos)
    
    width       = floor(wl/2);
    winStart    = max(1, (winPos(i) - width));
    winEnd      = min(nb_pnt(data), (winPos(i) + width));
    
    tmp         = var(data(:, winStart:winEnd), 0, 2);
    
    topVar(winPos(i)) = prctile(tmp, perc(2));
    lowVar(winPos(i)) = prctile(tmp, perc(1));
    
    if ~mod(i, by100) && verbose,
        eta(tinit, numel(winPos), i, 'remaintime', false);
    end
    
end

if verbose,
    fprintf('\n\n');
    clear eta;
end

%% Interpolating variance
topVar = interp1(winPos, topVar(winPos), 1:nb_pnt(data), 'linear');
lowVar = interp1(winPos, lowVar(winPos), 1:nb_pnt(data), 'linear');

%% Find sustained periods of too high or too low variance
if verbose,
    fprintf([verboseLabel 'Definitive sample rejection of %s...'], ...
        get_name(data));
end

isBad = false(1, nb_pnt(data));

% The top-var value is not within a reasonable range
maxValTop = median(topVar)+MADs*mad(topVar, 1);
minValTop = max(median(topVar)-MADs*mad(topVar, 1), eps);
isBad(topVar > maxValTop | topVar < minValTop) = true;

% The low-var value is not within a reasonable range
maxValLow = median(lowVar)+MADs*mad(lowVar, 1);
minValLow = max(median(lowVar)-MADs*mad(lowVar, 1), eps);
isBad(lowVar > maxValLow | lowVar < minValLow) = true;

%% Discard too short periods of bad samples
isReallyBad = false(1, nb_pnt(data));
runningCount = 0;
tinit=tic;
by100 = floor(numel(isBad)/100);

for i = 1:numel(isBad)
    if isBad(i)
        runningCount = runningCount + 1;
    else
        runningCount = 0;
    end
    if isBad(i) && runningCount >= minDur,
        isReallyBad(i) = true;
    end
    if ~mod(i, by100) && verbose,
        eta(tinit, numel(isBad), i, 'remaintime', false);
    end
end

data = set_bad_sample(data, isReallyBad);

if verbose,
    fprintf('\n\n');
    clear misc.eta;
end

if verbose, ...
        
        badSampleCount = numel(find(is_bad_sample(data)));
        
        fprintf([verboseLabel ...
        '%d (%d%%) samples were rejected\n\n'], ...
        badSampleCount, round(badSampleCount/nb_pnt(data)*100));
    
end

idx = find(is_bad_sample(data));

%% Generate rejection report

if do_reporting(obj),

    % Generate a report.object on this node
    if verbose,
        fprintf([verboseLabel 'Generating variances report...']);
    end
    
    bad_samples.generate_var_report(get_report(obj), isReallyBad, lowVar, ...
        topVar, minValLow, maxValLow, minValTop, maxValTop);
    
    if verbose, fprintf('[done]\n\n'); end
end


end