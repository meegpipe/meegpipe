function [status, MEh] = test_eog()
% TEST_EOG- Tests EOG correction

import mperl.file.spec.*;
import test.simple.*;
import pset.session;
import safefid.safefid;
import datahash.DataHash;
import misc.rmdir;
import oge.has_oge;

MEh     = [];

initialize(11);

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

%% process random data: no EOG components
try    
  
    name = 'process random data: no EOG components';
    
    X = rand(4, 5000);
   
    eegSensors = sensors.eeg.from_template('egi256', 'PhysDim', 'uV');
   
    eegSensors = subset(eegSensors, 1:4);
    
    importer = physioset.import.matrix(250, 'Sensors', eegSensors);
    
    data = import(importer, X);
    
    myNode = meegpipe.node.bss.eog('GenerateReport', true);
    run(myNode, data);
    
    ok(max(abs(data(:)-X(:))) < 1e-2, name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% Cleanup
try
    
    name = 'cleanup';
    clear data dataCopy;
    rmdir(session.instance.Folder, 's');
    session.clear_subsession();
    ok(true, name);
    
catch ME
    ok(ME, name);
end

%% Testing summary
status = finalize();