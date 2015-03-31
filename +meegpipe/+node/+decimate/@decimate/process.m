function [dataOut, dataNew] = process(obj, dataIn, varargin)
% PROCESS - Decimate a physioset
%
% See also: resample

import pset.pset;
import physioset.physioset;
import mperl.file.spec.catfile;
import misc.eta;

dataNew = [];

verbose      = is_verbose(obj);
verboseLabel = get_verbose_label(obj);

Q = get_config(obj, 'DownsampleBy');
P = 1;
outRate = get_config(obj, 'OutputRate');

if ~isnan(outRate),
    sr = dataIn.SamplingRate; 
    [P, Q] = rat(outRate/sr);
    if P > 1,
        error('Invalid output rate');
    end
end

%% Create output pointset full of NaNs
fileName = catfile(get_full_dir(obj), get_name(dataIn));
if verbose,  
    [~, tmpName] = fileparts(fileName);
    fprintf([verboseLabel 'Creating output pointset (%s) ...'], ...
        tmpName);
end

args = construction_args(dataIn, 'pset');
dataOut  = pset.nan(size(dataIn,1), ceil(P*size(dataIn,2)/Q), ...
    args{:}, 'FileName', fileName, 'Temporary', true);

if verbose, fprintf('[done]\n\n'); end

%% Resample input data and directly write it to output data file
if verbose,
    
    fprintf([verboseLabel ...
        'Decimating by %d/%d (from %d Hz to %.1f Hz)...'], ...
        P, Q, dataIn.SamplingRate, P/Q*dataIn.SamplingRate);
    
end

dataOut = decimate(dataIn.PointSet, Q, dataOut, 'verbose', verbose);

if verbose, fprintf('\n\n'); end

if verbose,
    
    [~, tmpName] = fileparts(fileName);
    fprintf([verboseLabel 'Updating physioset properties ... '], ...
        tmpName);
    
end

if verbose,
    fprintf('sampling time');
end
newSamplingRate = ceil(dataIn.SamplingRate*P/Q);
newSamplingTime = get_sampling_time(dataIn);
newSamplingTime = newSamplingTime(1:Q:end);
if verbose,
    fprintf(':ok ... ');
end

if verbose,
    fprintf('bad samples');
end

newBadSample = is_bad_sample(dataIn);
newBadSample = newBadSample(1:Q:end);
if verbose,
    fprintf(':ok ... ');
end

if verbose,
    fprintf('events ');
end
event = get_event(dataIn);
if ~isempty(event)
    event = resample(get_event(dataIn), P, Q);
end
if verbose,
    fprintf(':ok ... ');
end

if verbose, fprintf('[done]\n\n'); end

%% Create physioset object
if verbose,
    fprintf([verboseLabel 'Generating a physioset object...']);
end

% Generate an output physioset object

args = construction_args(dataIn);

dataOut = physioset.from_pset(dataOut, ...
    args{:}, ...
    'Name',             get_name(dataIn), ...
    'SamplingRate',     newSamplingRate, ...
    'Event',            event, ...
    'SamplingTime',     newSamplingTime, ...
    'BadSample',        newBadSample, ...
    'BadChannel',       is_bad_channel(dataIn));

set_meta(dataOut, get_meta(dataIn));

% Keep also the processing history
% VERY IMPORTANT: Don't know why (yet) but if you don't do this then the
% report of the pipeline that contains the current resample node will have
% its FID closed
procH = get_processing_history(dataIn);
for i = 1:numel(procH)
    add_processing_history(dataOut, procH{i});
end

if verbose,
    fprintf( '[done]\n\n');
end


end