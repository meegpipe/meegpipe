function [status, MEh] = test_eeglab()
% TEST_EEGLAB - Test conversion to EEGLAB format

import test.simple.*;
import mperl.file.spec.*;
import physioset.*;
import pset.session;
import safefid.safefid;
import datahash.DataHash;
import misc.rmdir;

MEh     = [];

initialize(4);

%% Create a new session
try
    
    name = 'create new session';
    warning('off', 'session:NewSession');
    session.instance;
    warning('on', 'session:NewSession');
    hashStr = DataHash(randn(1,100));
    session.subsession(hashStr(1:5));
    ok(true, name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% dealing with bad data: reject
try
    
    name = 'dealing with bad data: reject';
   
    [~, data] = sample_data(1);
    
    data = data{1};
    
    set_bad_sample(data, [100:200 500:600]);
    
    eeglabStr = eeglab(data);
    
    ok( ...
        isstruct(eeglabStr) & ...
        isfield(eeglabStr, 'chanlocs') & ...
        numel(eeglabStr.chanlocs) == 5 & ...
        all(ismember({eeglabStr.chanlocs.labels}, ...
        orig_labels(sensors(data)))) & ...
        isfield(eeglabStr, 'event') & ...
        numel(eeglabStr.event) == 10 & ...
        strcmp(eeglabStr.event(2).type, 'boundary') & ...
        strcmp(eeglabStr.event(6).type, 'boundary') & ...
        eeglabStr.event(2).latency == 99 & ...
        eeglabStr.event(6).latency == 398 & ...
        numel(get_event(data)) == 12, ...
        ...
        name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end


%% convert multiple datasets to eeglab
try
    
    name = 'merging multiple datasets into a eeglab structure';
    
    [~, data] = sample_data(3);
    
    eeglabStr = eeglab(data{:});
    
    ok( ...
        iscell(eeglabStr) & numel(eeglabStr) == 3, ...
        ...
        name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end


%% Cleanup
try
    
    name = 'cleanup';
    clear data ans;
    rmdir(session.instance.Folder, 's');
    session.clear_subsession();
    ok(true, name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% Testing summary
status = finalize();

end


function [file, data] = sample_data(nbFiles)

if nargin < 1 || isempty(nbFiles),
    nbFiles = 2;
end

file = cell(1, nbFiles);
data = cell(1, nbFiles);

mySens = sensors.eeg.from_template('egi256');
mySens = subset(mySens, 1:5);
myImporter = physioset.import.matrix('Sensors', mySens);

for i = 1:nbFiles 
   
   data{i} =  import(myImporter, rand(5, 1000));
   evArray = physioset.event.event(1:100:1000, 'Type', num2str(i));
   add_event(data{i}, evArray);
   file{i} = get_datafile(data{i});
   
   save(data{i});
   
end


end