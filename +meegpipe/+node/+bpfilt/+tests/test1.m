function [status, MEh] = test1()
% TEST1 - Tests basic node functionality

import mperl.file.spec.*;
import meegpipe.node.bpfilt.*;
import test.simple.*;
import pset.session;
import safefid.safefid;
import datahash.DataHash;
import misc.rmdir;
import oge.has_oge;

MEh     = [];

initialize(8);

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
    bpfilt; 
    ok(true, name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% constructor with config options
try
    
    name = 'construct low pass filter';
    bpfilt('BpFilt', filter.bpfilt('fp', [0 0.5]));
    ok(true, name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% process sample data
try
    
    name = 'process sample data';
    data = import(physioset.import.matrix, randn(10, 1000));
    dataOrig = data(:,:);
    myNode = bpfilt('BpFilt', filter.bpfilt('fp', [0 0.1]));
    run(myNode, data);
    
    ok(max(abs(data(:)-dataOrig(:))) > eps, name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% save node output
try
    
    name = 'save node output';
    data = import(physioset.import.matrix, randn(10, 1000));
    
    myNode = bpfilt('BpFilt', filter.bpfilt('fp', [0 0.5]), ...
        'Save', true);
    run(myNode, data);
    
    ok(exist(get_output_filename(myNode, data), 'file')>0, name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end


%% process multiple files
try
    
    name = 'process multiple datasets';
    % create 3 random physioset objects
    data = cell(1, 3);
    for i = 1:3,
        data{i} = import(physioset.import.matrix, randn(10, 1000));
    end
    myFilter = filter.bpfilt('fp', [0 0.5]);
    myNode = bpfilt('BpFilt', myFilter, 'Save', false, 'OGE', false);
    run(myNode, data{:});
    ok(true, name);
    
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% oge
try
    
    name = 'oge';
    if has_oge,
        
        data = cell(1, 3);
        for i = 1:3,
            data{i} = import(physioset.import.matrix, randn(10, 1000));
           
        end
        
        myFilter = filter.bpfilt('fp', [0 0.5]);
        myNode = bpfilt('BpFilt', myFilter, 'Save', false, 'OGE', true);
        dataFiles = run(myNode, data{:});
        pause(5); % give time for OGE to do its magic
        MAX_TRIES = 50;
        tries = 0;
        while tries < MAX_TRIES && ~exist(dataFiles{3}, 'file'),
            pause(1);
            tries = tries + 1;
        end
        
        ok(exist(dataFiles{3}, 'file') > 0, name);
        
    else
        ok(NaN, name, 'OGE is not available');
    end
    
    
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