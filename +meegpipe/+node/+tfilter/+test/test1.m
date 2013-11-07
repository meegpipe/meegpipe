function [status, MEh] = test1()
% TEST1 - Tests basic node functionality

import mperl.file.spec.*;
import meegpipe.node.tfilter.*;
import test.simple.*;
import pset.session;
import safefid.safefid;
import datahash.DataHash;
import misc.rmdir;
import oge.has_oge;
import oge.has_condor;
import misc.get_username;

MEh     = [];

initialize(10);

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
    tfilter; 
    ok(true, name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end


%% process sample data
try
    
    name = 'process sample data';

    data = import(physioset.import.matrix, randn(2,500));
    
    myFilter = filter.lasip('Gamma', 1, 'Scales', 1:10);
    myNode = tfilter('Filter', myFilter); 
    run(myNode, data);
    
    ok(true, name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% use IO report
try
    
    name = 'use IO report';

    data = import(physioset.import.matrix, randn(2,500));
    
    myFilter = filter.lasip('Gamma', 1, 'Scales', 1:10);
    myNode = tfilter('Filter', myFilter, 'IOReport', report.plotter.io); 
    run(myNode, data);
    
    ok(true, name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end


%% process in data chunks
try
    
    name = 'process in data chunks';

    data = import(physioset.import.matrix, randn(2,1200));
    
    chopEvents = physioset.event.std.chop_begin([1 301 601 901], ...
        'Duration', 300, 'Type', 'tfilter');
    
    add_event(data, chopEvents);
    
    import physioset.event.class_selector;
    myNode = tfilter(...
        'ChopSelector', class_selector('Class', 'chop_begin'), ...
        'Filter', filter.lasip('Gamma', 1, 'Scales', 1:10));
    run(myNode, data);
    
    ok(true, name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% save node output
try
    
    name = 'save node output';    
   
    data = import(physioset.import.matrix, randn(2,500));
    
    myNode = tfilter(...
        'Filter', filter.lasip('Gamma', 1, 'Scales', 1:10), 'Save', true);
    
    run(myNode, data);
    
    ok(exist(get_output_filename(myNode, data), 'file')>0, name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% process multiple files
try
    
    name = 'process multiple datasets';
    
    data = cell(1, 2);
    for i = 1:2,
        data{i} = import(physioset.import.matrix, randn(2,1000));
    end
    myFilter = filter.lasip(...
        'Filter', filter.lasip('Gamma', 1, 'Scales', 1:10), 'OGE', false);
    myNode = tfilter('Filter', myFilter); 
    origData = data{end}(1,:);
    run(myNode, data{:});
    ok(max(abs(data{end}(1,:)-origData)) > 1e-3, name);
    
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% oge
try
    
    name = 'oge';
    
    if has_oge,
        
        data = cell(1, 2);
        for i = 1:2,
            data{i} = import(physioset.import.matrix, randn(2,1000));
        end
        
         myNode = tfilter(...
             'Filter',  filter.lasip('Gamma', 1, 'Scales', 1:10), ...
             'OGE',     true, 'Queue', 'short.q');
        dataFiles = run(myNode, data{:});
        
        pause(5); % give time for OGE to do its magic
        MAX_TRIES = 45;
        tries = 0;
        while tries < MAX_TRIES && ~exist(dataFiles{3}, 'file'),
            pause(1);
            tries = tries + 1;
        end
        
        [~, ~] = system(sprintf('qdel -u %s', get_username));
        
        ok(exist(dataFiles{end}, 'file') > 0, name);
        
    else
        ok(NaN, name, 'OGE is not available');
    end
    
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% condor
try
    
    name = 'condor';
    
    if has_condor,
        
        data = cell(1, 2);
        for i = 1:2,
            data{i} = import(physioset.import.matrix, randn(2,1000));
        end
        
         myNode = tfilter(...
             'Filter',          filter.lasip('Gamma', 1, 'Scales', 1:10), ...
             'Parallelize',     true, 'Queue', 'condor', 'Save', true);
        dataFiles = run(myNode, data{:});
        
        pause(5); % give time for Condor to do its magic
        MAX_TRIES = 45;
        tries = 0;
        while tries < MAX_TRIES && ~exist(dataFiles{2}, 'file'),
            pause(3);
            tries = tries + 1;
        end
        
        [~, ~] = system(sprintf('condor_rm %s', get_username));
        [~, ~] = system(sprintf('source ~/.bashrc;condor_rm %s', get_username));
        
        ok(exist(dataFiles{end}, 'file') > 0, name);
        
    else
        ok(NaN, name, 'Condor is not available');
    end
    
    
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