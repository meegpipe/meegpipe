function [status, MEh] = test_ftrip()
% test_ftrip - Test conversion to fieldtrip format

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

%% convert a single dataset to fieldtrip
try
    
    name = 'convert a single dataset to fieldtrip';
   
    [~, data] = sample_data(1);
    
    ftripData = fieldtrip(data{:});
    
    ok( ...
        isstruct(ftripData) & ...
        isfield(ftripData, 'trial') & ...
        iscell(ftripData.trial) & ...
        numel(ftripData.trial) == 1 & ...
        all(size(ftripData.trial{1}) == size(data{1})), ...
        ...
        name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end


%% convert multiple datasets to fieldtrip
try
    
    name = 'merging multiple datasets into a fieldtrip structure';
    
    [~, data] = sample_data(3);
    
    ftripData = fieldtrip(data{:});
    
    ok( ...
        iscell(ftripData) & numel(ftripData) == 3, ...
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