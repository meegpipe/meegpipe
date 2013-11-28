function [status, MEh] = test_hierarchical_bss()
% TEST_HIERARCHICAL_BSS - Test BSS algorithms

import test.simple.*;
import mperl.file.spec.*;
import physioset.*;
import pset.session;
import safefid.safefid;
import datahash.DataHash;
import misc.rmdir;
import meegpipe.node.*;

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
    MEh = [MEh ME];
    
end

%% default constructor
try
    
    name = 'default constructor';
    
    obj = spt.bss.hierarchical_bss;
    
    ok(isa(obj, 'spt.spt') & isa(obj, 'spt.bss.hierarchical_bss'), name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% single level (window) usage with efica
try
    
    name = 'single level (window) usage with efica';
    
    mySensors = subset(sensors.eeg.from_template('egi256'), 1:3);
    myImporter = physioset.import.matrix('Sensors', mySensors);
    data =  import(myImporter, rand(3, 50000));
    
    myBSS = spt.bss.hierarchical_bss(spt.bss.efica);
    
    myBSS = learn(myBSS, data);
    
    error = bprojmat(myBSS)*projmat(myBSS)-eye(size(data,1));
    
    ok(...
        cond(projmat(myBSS)*eye(size(data,1))) < 2 & ...
        max(max(abs(error))) < 0.01, name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end



%% reproducibility of amica
try
    
    name = 'reproducibility of amica';
    
    X = rand(3, 15000);
    
    isCool = true;
    for i = 1:10,
        
        obj = spt.bss.amica;
        
        obj = learn(obj, X);
        
        W  = projmat(obj);
        
        A  = bprojmat(learn(obj, X));
        
        obj = clear_state(obj);
        
        A2  = bprojmat(learn(obj, X));
        
        isCool = isCool & rcond(W*A) > rcond(W*A2) & ...
            max(max(abs(W*A-eye(size(X,1))))) < 0.01;
        
    end
    
    ok(isCool, name);
    
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


function data = sample_data()


mySensors = subset(sensors.eeg.from_template('egi256'), 1:5);
myImporter = physioset.import.matrix('Sensors', mySensors);
data =  import(myImporter, rand(5, 10000));

end