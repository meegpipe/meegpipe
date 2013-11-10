function [status, MEh] = test_operators()
% TEST_OPERATORS - Test basic mathematic operators

import mperl.file.spec.*;
import pset.*;
import test.simple.*;
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

%% pow()
try
    
    name = 'pow()';
    data = pset.pset.randn(2,3000);
    origData = data(:,:);
    dataNew = data.^2;
    condition = max(abs(dataNew(:) - data(:))) < 0.01 & ...
        max(abs(origData(:).^2 - data(:))) < 0.01;
    ok(condition, name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% var()
try
    
    name = 'var()';
    data = 5+pset.pset.randn(5,3000);
    
    origData = data(:,:);
    trueVar = var(data(:,:), [], 2);
    psetVar = var(data, [], 2);
    
    ok(max(abs(trueVar-psetVar)) < 0.1 & ...
        max(abs(origData(:)-data(:))) < 0.01, name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% Cleanup
try
    
    name = 'cleanup';
    clear obj ans;
    pause(1);
    rmdir(session.instance.Folder, 's');
    session.clear_subsession();
    rmdir(session.instance.Folder, 's');
    ok(true, name);
    
catch ME
    ok(ME, name);
    MEh = [MEh ME];
end


status = finalize();
