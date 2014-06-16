function physiosetObj = import(obj, varargin)
% IMPORT - Imports disk files using Fieldtrip fileio module
%
% pObj = import(obj, fileName)
% pObjArray = import(obj, fileName1, fileName2, ...);
%
% See also: mff

%
%
% ## Secondary key/value pairs:
%
% 'Value2Type'  : (mjava.hash) A hash defining a mapping from event
%                 values (i.e. trigger values) to event types. See notes
%                 below for an example.
%                 Default: [], i.e. identity mapping

%

%
%
% Notes:
%
% * The epoch range has to be specified either in samples or in time but not
%   in both
%
% * If the optional argument folder is provided, then the fileName
%   mandatory argument must be empty
%
% * The following Value2Type mapping:
%
%   val2typeMap = mjava.hash;
%   val2typeMap{1:3} = 'Cue';
%   val2typeMap{4:6} = 'Target';
%
%   will map trigger values 1, 2, 3 to an event of type Cue (and value
%   corresponding to the trigger value) and will map trigger values 4:6 to
%   an event of type 'Target' and value matching the corresponding trigger
%   value.
%
% See also: fileio

import pset.globals;
import safefid.safefid;
import exceptions.*;
import misc.trigger2code;
import misc.decompress;
import pset.file_naming_policy;
import misc.sizeof;
import misc.eta;
import physioset.import.fileio;
import physioset.physioset;
import misc.check_dependency;

if numel(varargin) == 1 && iscell(varargin{1}),
    varargin = varargin{1};
end

% Deal with the multi-newFileName case
if nargin > 2
    physiosetObj = cell(numel(varargin), 1);
    for i = 1:numel(varargin)
        physiosetObj{i} = import(obj, varargin{i});
    end
    return;
end

fileName = varargin{1};
[fileName, obj] = resolve_link(obj, fileName);

% Default values of optional input arguments
verbose      = is_verbose(obj);
verboseLabel = get_verbose_label(obj);
origVerboseLabel = goo.globals.get.VerboseLabel;
goo.globals.set('VerboseLabel', verboseLabel);

% Configuration options
eegRegex        = obj.EegRegex;
megRegex        = obj.MegRegex;
physRegex       = obj.PhysRegex;
trigRegex       = obj.TriggerRegex;
eegRegexTrans   = obj.EegTransRegex;
megRegexTrans   = obj.MegTransRegex;
physRegexTrans  = obj.PhysTransRegex;
graduRegex      = obj.GradUnitRegex;
mustEqualize    = obj.Equalize;

% The input file might be zipped
[status, fileName] = decompress(fileName, 'Verbose', verbose);
isZipped = ~status;

% Determine the names of the generated (imported) files
if isempty(obj.FileName),
    
    newFileName = file_naming_policy(obj.FileNaming, fileName);
    dataFileExt = globals.get.DataFileExt;
    newFileName = [newFileName dataFileExt];
    
else
    
    newFileName = obj.FileName;
    
end

% EEGLAB already contains fileio
check_dependency('eeglab');

%% Read header
if verbose,
    fprintf([verboseLabel 'Reading header...']);
end

[~, hdr] = evalc( ['ft_read_header(''' fileName ''')'] );
if verbose,
    fprintf('[done]\n\n')
end

sr = hdr.Fs;

%% Read signal values
[~, name] = fileparts(newFileName);
if verbose,
    
    fprintf('%sWriting data to %s...', verboseLabel, name);
end
tinit = tic;
chunkSize = floor(obj.ChunkSize/(sizeof(obj.Precision)*hdr.nChans)); % in samples
if hdr.nTrials > 1,
    % Chunk size must be an integer number of trials
    chunkSize = floor(chunkSize/(hdr.nSamples))*hdr.nSamples;
end
boundary = 1:chunkSize:(hdr.nSamples*hdr.nTrials);
if length(boundary)<2 || boundary(end) < hdr.nSamples*hdr.nTrials,
    boundary = [boundary,  hdr.nSamples*hdr.nTrials+1];
else
    boundary(end) = boundary(end)+1;
end
nbChunks = length(boundary) - 1;
fid = safefid(newFileName, 'w');
if ~fid.Valid, throw(InvalidFID(newFileName)); end

% Identify channels for trigger data/MEG data/EEG data/Physiology data
isEeg = cellfun(@(x) ~isempty(x), regexpi(hdr.label(:), eegRegex));

isMeg = ~isEeg & ...
    cellfun(@(x) ~isempty(x), regexpi(hdr.label(:), megRegex));


isTrigger = ~isEeg & ~isMeg & ...
    cellfun(@(x) ~isempty(x), regexpi(hdr.label(:), trigRegex));

isPhys = ~isEeg & ~isMeg & ~isTrigger & ...
    cellfun(@(x) ~isempty(x), regexpi(hdr.label(:), physRegex));


if ~isfield(hdr, 'unit') && isfield(hdr, 'chanunit'),
    hdr.unit = hdr.chanunit;
end

if any(isMeg),
    isGrad    = cellfun(@(x) ~isempty(x), regexpi(hdr.unit(:),  graduRegex));
    isGrad    = isMeg & isGrad;
    isMag     = isMeg & ~isGrad;
    gradIdx = find(isGrad(:));
    magIdx  = find(isMag(:));
else
    gradIdx = [];
    magIdx = [];
    isMag = false(size(isMeg));
    isGrad = false(size(isMeg));
end


megIdx  = [gradIdx;magIdx];
eegIdx  = find(isEeg(:));
physIdx = find(isPhys(:));

triggerData = nan(numel(find(isTrigger)), hdr.nSamples);

varEeg  = 0;
varPhys = 0;
varGrad = 0;
varMag  = 0;
nbChans = NaN;
for chunkItr = 1:nbChunks
    begSample = boundary(chunkItr);
    endSample = boundary(chunkItr+1)-1;
    [~, dat] = evalc( ...
        ['ft_read_data(fileName, ' ...
        '''begsample'',        begSample, ' ...
        '''endsample'',        endSample, ' ...
        '''checkboundary'',    false, '...
        '''header'',           hdr)']);
    nbChans = size(dat, 1);
    if ndims(dat) > 2, %#ok<ISMAT>
        dat = reshape(dat, [size(dat,1), round(numel(dat)/size(dat,1))]);
    end
    % Keep track of the variance of each signal type for equalizing later
    if ~isempty(gradIdx),
        varGrad  = varGrad + median(var(dat(gradIdx,:),[],2));
    end
    if ~isempty(magIdx),
        varMag  = varMag + median(var(dat(magIdx,:),[],2));
    end
    if ~isempty(eegIdx),
        varEeg  = varEeg + median(var(dat(eegIdx,:),[],2));
    end
    if ~isempty(physIdx),
        varPhys  = varPhys + median(var(dat(physIdx,:),[],2));
    end
    % MEG, EEG and EOG is to be written but not trigger data
    triggerData(:, begSample:endSample) = dat(isTrigger,:);
    dat         = dat([gradIdx; magIdx; eegIdx; physIdx], :);
    
    % Write the chunk into the output binary file
    fwrite(fid, dat(:), obj.Precision);
    if verbose,
        eta(tinit, nbChunks, chunkItr);
    end
end
fid.fclose;

% Fix the order of the channels in the header
if isfield(hdr, 'grad')
    hdr.grad    = fileio.grad_reorder(hdr.grad, megIdx);
    hdr.grad    = fileio.grad_change_unit(hdr.grad, 'cm');
    hdr.label   = hdr.label([gradIdx; magIdx; eegIdx; physIdx]);
    hdr.unit    = hdr.unit([gradIdx; magIdx; eegIdx; physIdx]);
end

% Fix the channel order in gradIdx, etc.
gradIdx = 1:numel(gradIdx);
magIdx  = numel(gradIdx)+1:numel(gradIdx)+numel(magIdx);
eegIdx  = numel(gradIdx)+numel(magIdx)+1:numel(gradIdx)+...
    numel(magIdx)+numel(eegIdx);
physIdx = numel(gradIdx)+numel(magIdx)+numel(eegIdx)+1:...
    numel(gradIdx)+numel(magIdx)+numel(eegIdx)+numel(physIdx);
if verbose, fprintf('\n\n'); end

%% Convert trigger data to events
if verbose,
    fprintf([verboseLabel 'Reading events...']);
end
events = [];
for i = 1:size(triggerData,1),
    [sample, code] = trigger2code(triggerData);
    for j = 1:numel(code),
        thisValue = code(j);
        if ~isempty(obj.Trigger2Type),
            thisType  = obj.Trigger2Type(code(j));
        else
            thisType = [];
        end
        if isempty(thisType),
            thisType = num2str(code(j));
        end
        thisEvent = physioset.event.event(sample(j), ...
            'Type', thisType, 'Value', thisValue);
        events = [events;thisEvent]; %#ok<AGROW>
    end
end
if verbose, fprintf('[done]\n\n'); end

%% Sensor information
if isempty(obj.Sensors),
    
    if verbose,
        fprintf([verboseLabel 'Reading sensor information...']);
    end
    eegSensors  = [];
    magSensors  = [];
    gradSensors = [];
    physSensors = [];
    
    if any(isEeg),
        eegLabels = cellfun(@(x) regexprep(x, eegRegex, eegRegexTrans), ...
            hdr.label(eegIdx), 'UniformOutput', false);
        eegSensors  = sensors.eeg(...
            'Label',     eegLabels, ...
            'OrigLabel', hdr.label(eegIdx));
    end
    
    if any(isMag),
        magLabels = cellfun(@(x) regexprep(x, megRegex, megRegexTrans), ...
            hdr.label(magIdx), 'UniformOutput', false);
        % Sensors for the magnetometers
        if isfield(hdr.grad, 'coilpos'),
            % Old Fieldtrip version
            magCoils    = sensors.coils(...
                'Cartesian',    hdr.grad.coilpos, ...
                'Orientation',  hdr.grad.coilori, ...
                'Weights',      hdr.grad.tra(magIdx, :));
            magSensors  = sensors.meg(...
                'Coils',        magCoils, ...
                'Cartesian',    hdr.grad.chanpos(magIdx,:), ...
                'Orientation',  hdr.grad.chanori(magIdx,:), ...
                'PhysDim',      hdr.unit(magIdx), ...
                'Label',        magLabels, ...
                'OrigLabel',    hdr.label(magIdx));
        elseif isfield(hdr.grad, 'pnt'),
            % Old Fieldtrip does not specify coils positions/orientations
            magCoils = sensors.coils('Weights', hdr.grad.tra(magIdx,:));
            magSensors  = sensors.meg(...
                'Coils',        magCoils, ...
                'Cartesian',    hdr.grad.pnt(magIdx,:), ...
                'Orientation',  hdr.grad.ori(magIdx,:), ...
                'PhysDim',      'T', ...
                'Label',        magLabels, ...
                'OrigLabel',    hdr.label(magIdx));
        else
            error('Invalid Fieldtrip structure');
        end
    end
    
    if any(isGrad),
        gradLabels = cellfun(@(x) regexprep(x, megRegex, megRegexTrans), ...
            hdr.label(gradIdx), 'UniformOutput', false);
        % Sensors for the gradiometers
        if isfield(hdr.grad, 'coilpos'),
            gradCoils    = sensors.coils(...
                'Cartesian',    hdr.grad.coilpos, ...
                'Orientation',  hdr.grad.coilori, ...
                'Weights',      hdr.grad.tra(gradIdx, :));
            gradSensors  = sensors.meg(...
                'Coils',        gradCoils, ...
                'Cartesian',    hdr.grad.chanpos(gradIdx,:), ...
                'Orientation',  hdr.grad.chanori(gradIdx,:), ...
                'PhysDim',      hdr.unit(gradIdx), ...
                'Label',        gradLabels, ...
                'OrigLabel',    hdr.label(gradIdx));
        elseif isfield(hdr.grad, 'pnt'),
            gradCoils = sensors.coils('Weights', hdr.grad.tra(gradIdx,:));
            gradSensors  = sensors.meg(...
                'Coils',        gradCoils, ...
                'Cartesian',    hdr.grad.pnt(gradIdx,:), ...
                'Orientation',  hdr.grad.ori(gradIdx,:), ...
                'PhysDim',      'T/m', ...
                'Label',        gradLabels, ...
                'OrigLabel',    hdr.label(gradIdx));
        else
            error('Invalid Fieldtrip structure');
        end
        
    end
    
    if any(isPhys),
        physLabels = cellfun(@(x) regexprep(x, physRegex, physRegexTrans), ...
            hdr.label(physIdx), 'UniformOutput', false);
        physSensors = sensors.physiology(...
            'Label',    physLabels);
    end
    
    sensorsMixed = sensors.mixed(gradSensors, magSensors, eegSensors, ...
        physSensors);
    
    if verbose, fprintf('[done]\n\n'); end
    
else
    
    if verbose,
        fprintf([verboseLabel 'Sensor information explicity provided ...\n\n']);
    end
    sensorsMixed = obj.Sensors;
    
end


%% Generate output object
if verbose,
    fprintf('%sGenerating a physioset object...', verboseLabel);
end
% Generate the output physioset object
physiosetArgs = construction_args_physioset(obj);

if isnan(nbChans) || nb_sensors(sensorsMixed) < 1
    error('fileio:import', 'Did not recognize any valid sensor in file %s', ...
        fileName);
end

physiosetObj  = physioset(newFileName, nb_sensors(sensorsMixed), ...
    'Name',             name, ...
    'SamplingRate',     sr, ...
    'Event',            events, ...
    'Sensors',          sensorsMixed, ...
    physiosetArgs{:});

physiosetObj = set_meta(physiosetObj, 'hdr', hdr);

if verbose, fprintf('[done]\n\n'); end

if mustEqualize
    
    if verbose,
        fprintf([verboseLabel 'Equalizing...']);
    end
    physiosetObj = equalize(physiosetObj, 'Verbose', verbose);
    if verbose, fprintf('\n\n'); end
    
end


%% Undoing stuff

% Unset the global verbose
goo.globals.set('VerboseLabel', origVerboseLabel);

% Delete unzipped data file
if isZipped,
    delete(fileName);
end


end