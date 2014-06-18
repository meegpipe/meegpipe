function [status, MEh] = test_tutorial_emg()
% TEST_TUTORIAL_EMG - Tests that the EMG removal tutorial works

import mperl.file.spec.*;
import pset.*;
import test.simple.*;
import pset.session;
import safefid.safefid;
import datahash.DataHash;
import misc.rmdir;

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

%% download sample dataset
try
    
    name = 'download sample dataset';
    url = 'https://dl.dropboxusercontent.com/u/4479286/meegpipe/f1_750to810.set';
    file = catfile(session.instance.Folder, 'f1_750to810.set');
    urlwrite(url, file);
    ok(exist(file, 'file') > 0, name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end


%% build the pipeline
try
    name = 'build the pipeline';
    myPipe = tutorial_emg.create_pipeline('GenerateReport', true);
    ok(true, name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% run the pipeline
try
    name = 'run the pipeline';
    run(myPipe, file);
    rootDir = get_full_dir(myPipe, file);
    ok(exist(catfile(rootDir, 'directory.htm'), 'file')>0, name);
    
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
