function [status, MEh] = test1()
% TEST1 - Tests basic node functionality

import mperl.file.spec.*;
import meegpipe.node.*;
import test.simple.*;
import pset.session;
import safefid.safefid;
import datahash.DataHash;
import misc.rmdir;
import oge.has_oge;

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
    status = finalize();
    return;
    
end


%% default constructor
try
    
    name = 'constructor';
    abp.new;
    ok(true, name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% process sample data
try
    
    name   = 'process sample data';
    
    tmp = load(catfile(meegpipe.root_path, '+data', 'ecg.mat'), 'ecg');
    ecg = tmp.ecg;
    
    mySensors  = sensors.physiology('Label', 'ECG');
    myImporter = physioset.import.matrix('Sensors', mySensors);
    
    data = import(myImporter, ecg);
    
    myPipe = pipeline.new('NodeList', {qrs_detect.new, abp.new});
    
    run(myPipe, data);  
   
    ok(true, name);
    clear data;
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end


%% Cleanup
try
    
    name = 'cleanup';   
    clear data dataCopy myNode myPipe;
    rmdir(session.instance.Folder, 's');
    session.clear_subsession();
    ok(true, name);
    
catch ME
    ok(ME, name);
end

%% Testing summary
status = finalize();

end
