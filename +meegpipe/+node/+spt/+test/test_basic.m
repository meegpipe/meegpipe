function [status, MEh] = test_basic()
% TEST_BASIC - Tests basic node functionality

import test.simple.*;

import mperl.file.spec.*;
import meegpipe.*;
import pset.session;
import safefid.safefid;
import datahash.DataHash;
import misc.rmdir;
import oge.has_oge;
import oge.has_condor;
import misc.get_username;

MEh     = [];

initialize(4);

%% Create a new session
try
    
    name = 'create new session';
    warning('off', 'session:NewSession');
    session.instance;
    warning('on', 'session:NewSession');   
    session.subsession;
    ok(true, name);
    
catch ME
    
    ok(ME, name);
    status = finalize();
    return;
    
end


%% default constructor
try
    
    name = 'constructor';
    node.spt.new; 
    ok(true, name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end


%% process sample data
try
    
    name = 'process sample data';

    data = import(physioset.import.matrix, randn(5,5000));
    
    myNode = node.spt.new(...
        'SPT',      spt.bss.jade, ...
        'PCA',      spt.pca('MinCard', 3, 'MaxCard', 3)); 
    dataNew = run(myNode, data);
    
    ok(size(dataNew, 1) == 3, name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end


%% Cleanup
try
    
    name = 'cleanup';
    % just in case
    [~, ~] = system(sprintf('qdel -u %s', get_username));
    clear data dataCopy ans myCfg myNode;
    rmdir(session.instance.Folder, 's');
    session.clear_subsession();
    ok(true, name);
    
catch ME
    ok(ME, name);
end

%% Testing summary
status = finalize();

end