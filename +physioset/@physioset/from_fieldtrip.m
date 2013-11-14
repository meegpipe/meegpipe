function physObj = from_fieldtrip(str, varargin)
% FROM_FIELDTRIP - Construction from FIELDTRIP structure
%
% import physioset.
% obj = physioset.from_fieldtrip(str);
% obj = physioset.from_fieldtrip(str, 'key', value, ...)
%
% Where
%
% str is a Fieldtrip struct
%
% OBJ is an eegset object
%
%
% ## Accepted (optional) key/value pairs:
%
%       Filename : A valid file name (a string). Default: ''
%           The name of the memory-mapped file to which the generated
%           physioset will be linked.
%
%
% See also: from_pset, from_eeglab


import misc.process_arguments;
import misc.is_valid_filename;
import mperl.file.spec.catfile;
import physioset.physioset;
import pset.globals;
import physioset.event.event;
import physioset.event.std.trial_begin;
import pset.pset;
import physioset.import.matrix;
import exceptions.*;
import pset.session;


%% Error checking
if ~isstruct(str) || ~isfield(str, 'fsample'),
    ME = InvalidArgument('str', 'A Fieldtrip struct is expected');
    throw(ME);
end


%% Optional input arguments
opt.FileName    = '';

[~, opt] = process_arguments(opt, varargin);

if isempty(opt.FileName),        
    filename = session.instance.tempname;
    if is_valid_filename(filename),
        opt.FileName = filename;
    end
end

if isempty(opt.FileName),
    opt.FileName = pset.file_naming_policy('Random');
elseif ~is_valid_filename(opt.FileName),
    error('The provided file name is not valid');
end

fileExt = globals.get.DataFileExt;
[path, name] = fileparts(opt.FileName);
opt.FileName = catfile(path, [name fileExt]);

%% Sensor information
if isfield(str, 'grad'),  
    sensorsObj = sensors.meg.from_fieldtrip(str.grad, str.label); 
elseif isfield(str, 'elec'),
    sensorsObj = sensors.eeg.from_fieldtrip(str.elec, str.label);
else
    warning('physioset:MissingSensorInformation', ...
        ['Fieldtrip structure does not contain sensor information:' ...
        'Assuming vanilla EEG sensors.']);
    sensorsObj = sensors.eeg.empty();
end

% Create an event per trial
nEvents = numel(str.trial);
ev = repmat(event, nEvents, 1);
durAll = 0;
for i = 1:numel(str.trial),
  offset = -find(str.time{i} >= 0, 1)+1;
  if offset>=0,
    offset = round(offset/str.fsample);
  end
  sample = -offset + 1 + durAll;
  dur    = size(str.time{i}, 2);
  durAll = durAll + dur;
  
  thisEvent  = trial_begin(sample, ...  
    'Offset',       offset, ...
    'Duration',     dur);
  
  thisEvent = set_meta(thisEvent, ...
    'sampleinfo',   str.sampleinfo(i, :), ...
    'time',         str.time{i});
  
  if isfield(str, 'trialinfo')
    thisEvent = set_meta(thisEvent, ...
      'trialinfo', str.trialinfo(i, :));
  else
    thisEvent = set_meta(thisEvent, ...
      'trialinfo', []);
  end
    
  ev(i) = thisEvent;
end

data = [str.trial{:}];

%% Use the matrix importer to generate a physioset object
importer = matrix(str.fsample, ...
    'FileName',     opt.FileName, ...
    'Sensors',      sensorsObj);
physObj  = import(importer, data);

set_name(physObj, 'fieldtripdata');

%% Take care of the time property
if isfield(str, 'time'),
    physObj.SamplingTime = [str.time{:}];
end

%% Take care of extra fields, unique to Fieldtrip
extraFields = {'cfg', 'hdr', 'sampleinfo', 'trialinfo'};
for i = 1:numel(extraFields),
  if isfield(str, extraFields{i})
    set_meta(physObj, extraFields{i}, str.(extraFields{i}));
  end
end

%% Add to the physioset the trial events and the data events
add_event(physObj, ev); 
if isfield(str, 'cfg') && isfield(str.cfg, 'event')
    add_event(physObj, event.from_fieldtrip(str.cfg.event));
end
