function [status, MEh] = test1()
% TEST1 - Tests basic node functionality

import mperl.file.spec.*;
import meegpipe.node.obs.*;
import meegpipe.node.qrs_detect.qrs_detect;
import test.simple.*;
import pset.session;
import safefid.safefid;
import datahash.DataHash;
import misc.rmdir;
import oge.has_oge;
import misc.get_username;
import physioset.event.std.qrs;

MEh     = [];

initialize(5);

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
    status = finalize();
    return;
    
end


%% default constructor
try
    
    name = 'constructor';
    obs; 
    ok(true, name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% constructor from config object
try
    
    name = 'constructor from config object';
    myCfg = config('NPC',4);
    obs(myCfg);
    ok(true, name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% process sample data
try
    
    name   = 'process sample data';    
   
    ecgSens = sensors.physiology('Label', 'ECG');
    eegSens = sensors.eeg.dummy(5);
    sens = sensors.mixed(eegSens, ecgSens);
    myImporter = physioset.import.matrix('Sensors', sens);
    X = randn(6, 10000);
    data = import(myImporter, X);
    
    % Add some artificial QRS complex events
    add_event(data, qrs(1:100:10000));
    
    myNode = obs;
    
    run(myNode, data);
    
    % ensure the imported and original data are identical
    ok(max(abs(data(:)-X(:)))>0.1, name);
    clear data;
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end


%% Cleanup
try
    
    name = 'cleanup';
    % just in case
    [~, ~] = system(sprintf('qdel -u %s', get_username));
    clear data dataCopy myNode;
    rmdir(session.instance.Folder, 's');
    session.clear_subsession();
    ok(true, name);
    
catch ME
    ok(ME, name);
end

%% Testing summary
status = finalize();