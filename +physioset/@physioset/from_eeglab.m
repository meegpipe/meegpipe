function physObj = from_eeglab(str, varargin)
% FROM_EEGLAB - Construction from EEGLAB structure
%
% import physioset.
% physObj = physioset.from_eeglab(str, 'key', value, ...)
%
% Where
%
% STR is an EEGLAB structure
%
% PHYSOBJ is a physioset object
%
%
% ## Accepted (optional) key/value pairs:
%
%       Filename : A valid file name (a string). Default: ''
%           The name of the memory-mapped file to which the generated
%           physioset will be linked.
%
%       SensorClass : A cell array of strings. 
%           Default: repmat({'eeg', str.nbchan, 1)
%           The classes of the data sensors. Valid types are: eeg, meg,
%           physiology
%
% See also: from_pset, from_fieldtrip

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
if ~isstruct(str) || ~isfield(str, 'data') || ...
        ~isfield(str, 'chanlocs'),
    ME = InvalidArgument('str', 'An EEGLAB struct is expected');
    throw(ME);
end

%% Optional input arguments
opt.SensorClass  = repmat({'eeg'}, str.nbchan, 1);
opt.FileName    = '';

[~, opt] = process_arguments(opt, varargin);

if numel(opt.SensorClass) < str.nbchan,
    opt.SensorClass = [opt.SensorClass(:); ...
        repmat({'eeg'}, str.nbchan-numel(opt.SensorClass), 1)];
end

if isempty(opt.FileName),
    if ~isempty(str.filepath),
       filePath = str.filepath;
    else
       filePath = session.instance.Folder;
    end
    filename = catfile(filePath, str.setname);
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
uTypes = unique(opt.SensorClass);

% We need to ensure that same-type sensors are correlative
count = 0;
for i = 1:numel(uTypes)
   idx = find(ismember(opt.SensorClass, uTypes{i}));
   ordering(count+1:count+numel(idx)) = idx;
   count = count + numel(idx);
end

sensorGroups = cell(1, numel(uTypes));
if ~isempty(str.chanlocs),    
    for i = 1:numel(uTypes)
        chans = str.chanlocs(ismember(opt.SensorClass, uTypes{i})); %#ok<NASGU>
        sensorGroups{i} = ...
            eval(sprintf('sensors.%s.from_eeglab(chans);', ...
            lower(uTypes{i})));
    end
else
    for i = 1:numel(uTypes)
        nbSensors = numel(find(ismember(opt.SensorClass, uTypes{i})));
        sensorGroups{i} = eval(sprintf('sensors.%s.empty(%d);', ...
            uTypes{i}, nbSensors));
    end
end
if numel(sensorGroups) > 1,
    sensorObj = sensors.mixed(sensorGroups{:});
else
    sensorObj = sensorGroups{1};
end


%% Events information
eventsObj = event.from_eeglab(str.event);

% If it is an epoched dataset we need to add some extra events to tell so
if str.trials > 1,
   trialEvents = trial_begin(1:str.pnts:str.pnts*str.trials, ...
       'Duration', str.pnts); 
   eventsObj = [eventsObj(:); trialEvents(:)];
end


%% Use the matrix importer to generate a physioset object
data = reshape(str.data, str.nbchan, str.pnts*str.trials);

importer = matrix(str.srate, ...
    'FileName',     opt.FileName, ...
    'Sensors',      sensorObj);
physObj  = import(importer, data(ordering,:));

set_name(physObj, str.setname);
add_event(physObj, eventsObj);

% This might be handy when converting back to EEGLAB format
str.data    = [];
str.icaact  = [];
set_meta(physObj, 'eeglab', str);



end