function [status, MEh] = test1()
% TEST1 - Tests basic node functionality

import mperl.file.spec.*;
import meegpipe.node.smoother.*;
import chopper.ged;
import physioset.event.class_selector;
import physioset.event.std.*;
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
    smoother;
    ok(true, name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% constructor with config options
try
    
    name = 'construct node with config options';
    evSel  = class_selector('Class', 'discontinuity');
    myNode = smoother('EventSelector', evSel);
    ok(...
        isa(get_config(myNode, 'EventSelector'), ...
        'physioset.event.class_selector'), ...
        name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% process sample data
try
    
    name = 'process sample data';
    
    % random data with some discontinuities
    X = randn(10,1000);
    
    X(:,300:500) = X(:,300:500) + 3;
    X(:,700:800) = X(:,700:800) - 3;
    
    data = import(physioset.import.matrix, X);
    
    % Add events at the location of the discontinuities
    eventArray = physioset.event.std.discontinuity([300 500 700 800]);
    add_event(data, eventArray);
    
    myNode = smoother('MergeWindow', 0.3);
    run(myNode, data);
    
    ok(true, name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% save node output
try
    
    name = 'save node output';
   
    % random data with some discontinuities
    X = randn(10,1000);
    
    X(:,300:500) = X(:,300:500) + 3;
    X(:,700:800) = X(:,700:800) - 3;
    
    data = import(physioset.import.matrix, X);
    
    % Add events at the location of the discontinuities
    eventArray = physioset.event.std.discontinuity([300 500 700 800]);
    add_event(data, eventArray);
    
    myNode = smoother('MergeWindow', 0.3, 'Save', true);
    run(myNode, data);
    
    ok(exist(get_output_filename(myNode, data), 'file')>0, name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end


%% process multiple files
try
    
    name = 'process multiple datasets';
    
    data = cell(1, 3);
    for i = 1:3,
        X = randn(10,1000);
        
        X(:,300:500) = X(:,300:500) + 3;
        X(:,700:800) = X(:,700:800) - 3;
        data{i} = import(physioset.import.matrix, X);
    end
    
    myNode = smoother('MergeWindow', 0.3, 'Save', true);
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
        
        name = 'oge';
        
        data = cell(1, 3);
        for i = 1:3,
            X = randn(10,1000);
            
            X(:,300:500) = X(:,300:500) + 3;
            X(:,700:800) = X(:,700:800) - 3;
            data{i} = import(physioset.import.matrix, X);
        end
        
        myNode = smoother('MergeWindow', 0.3, 'Save', true);
        dataFiles = run(myNode, data{:});
        
        pause(5); % give time for OGE to do its magic
        MAX_TRIES = 100;
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