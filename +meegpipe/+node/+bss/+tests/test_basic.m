function [status, MEh] = test_basic()
% TEST_BASIC- Tests basic node functionality

import mperl.file.spec.*;
import meegpipe.node.*;
import test.simple.*;
import pset.session;
import safefid.safefid;
import datahash.DataHash;
import misc.rmdir;
import oge.has_oge;

MEh     = [];

initialize(10);

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
    bss.new;
    ok(true, name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% construction with key/values
try
    
    name = 'construction with key/values';
   
    regrFilter = filter.mlag_regr('Order', 5);
    myNode = bss.new('RegrFilter', regrFilter);    

    regrFilter = get_config(myNode, 'RegrFilter');
    ok( ...
        regrFilter.Order == 5, ...
        name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% process sample data: simple case
try    
  
    name = 'process sample data: simple case';
    
    X = rand(4, 5000);
    
    warning('off', 'sensors:InvalidLabel');
    eegSensors = sensors.eeg.from_template('egi256', 'PhysDim', 'uV');
    warning('on', 'sensors:InvalidLabel');
    
    eegSensors   = subset(eegSensors, 1:4);
    
    importer = physioset.import.matrix(250, 'Sensors', eegSensors);
    
    data = import(importer, X);
    
    myNode = meegpipe.node.bss.new('GenerateReport', true);
    run(myNode, data);
    
    ok(max(abs(data(:)-X(:))) < 1e-2, name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% threshold criterion
try    
  
    name = 'threshold criterion';
    
    X = rand(4, 5000);
    
    warning('off', 'sensors:InvalidLabel');
    eegSensors = sensors.eeg.from_template('egi256', 'PhysDim', 'uV');
    warning('on', 'sensors:InvalidLabel');
    
    eegSensors   = subset(eegSensors, 1:4);
    
    importer = physioset.import.matrix(250, 'Sensors', eegSensors);
    
    data = import(importer, X);
    
    myCrit = spt.criterion.threshold(spt.feature.tkurtosis, ...
        'Max', @(kurt) median(kurt));
    myNode = meegpipe.node.bss.new(...
        'GenerateReport',   true, ...
        'Criterion',        myCrit);
    run(myNode, data);
    
    ok(max(abs(data(:)-X(:))) < 1e-2, name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end



%% multiple sensor groups, bad samples, bad channels
try

    name = 'multiple sensor groups, bad samples, bad channels';
    
    X = rand(10, 20000);
    
    warning('off', 'sensors:InvalidLabel');
    eegSensors = sensors.eeg.from_template('egi256', 'PhysDim', 'uV');
    warning('on', 'sensors:InvalidLabel');
    
    eegSensors   = subset(eegSensors, 1:32:256);
    dummySensors = sensors.dummy(2);
    allSensors   = sensors.mixed(eegSensors, dummySensors);
    
    importer = physioset.import.matrix(250, 'Sensors', allSensors);
    data = import(importer, X);
    
    set_bad_sample(data, 50:2500);
    set_bad_channel(data, 1:3);
    
    myNode = meegpipe.node.bss.new('Reject', false);
    run(myNode, data);
    
    ok(max(abs(data(:)-X(:))) < 1e-3, name);
    
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% filtering and saving node output
try    

    name = 'filtering and saving node output';
    
    X = rand(8, 20000);
    
    warning('off', 'sensors:InvalidLabel');
    eegSensors = sensors.eeg.from_template('egi256', 'PhysDim', 'uV');
    warning('on', 'sensors:InvalidLabel');
    
    eegSensors = subset(eegSensors, 1:32:256);
    
    importer = physioset.import.matrix(250, 'Sensors', eegSensors);
    data = import(importer, X);
    
    myFilter = filter.lpfilt('fc', .5);
    myBSS    = spt.bss.jade('LearningFilter', myFilter);
    myNode = bss_regr('BSS', myBSS, 'Save', true);
    run(myNode, data);
    
    ok( exist(get_output_filename(myNode, data), 'file')>0, name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end



%% process multiple files
try
    
    name = 'process multiple datasets';
    
    data = cell(1, 3);
    for i = 1:3,
        data{i} = import(physioset.import.matrix, randn(10, 1000));
    end
    
    myNode = bss_regr.new('Save', true, 'Parallelize', false);
    run(myNode, data{:});
    
    MAX_TRIES = 20;
    tries = 0;
    while tries < MAX_TRIES && ~all(cellfun(@(x) ...
            exist(get_output_filename(myNode, x), 'file') > 0, data))
        pause(2); % give time to the file system to put things in place
        tries = tries + 1;
    end
    
    ok(all(cellfun(@(x) ...
        exist(get_output_filename(myNode, x), 'file') > 0, data)), ...
        name);
    
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% EOG correction
try

    name = 'EOG correction';
    
    X = randn(10, 50000);
    
    warning('off', 'sensors:InvalidLabel');
    eegSensors = sensors.eeg.from_template('egi256', 'PhysDim', 'uV');
    warning('on', 'sensors:InvalidLabel');
    
    eegSensors   = subset(eegSensors, 1:32:256);
    dummySensors = sensors.dummy(2);
    allSensors   = sensors.mixed(eegSensors, dummySensors);
    
    importer = physioset.import.matrix(250, 'Sensors', allSensors);
    data = import(importer, X);
    
    set_bad_sample(data, 50:2500);
    set_bad_channel(data, 1:3);
    
    myNode = bss_regr.eog('Var', 99.9);
    run(myNode, data);
    
    ok(max(abs(data(:)-X(:))) > 1e-3, name);
    
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% oge
try
    
    name = 'oge';
    
    if has_oge,
        
        warning('off', 'sensors:InvalidLabel');
        eegSensors = sensors.eeg.from_template('egi256', 'PhysDim', 'uV');
        warning('on', 'sensors:InvalidLabel');
        
        eegSensors   = subset(eegSensors, 1:32:256);
        dummySensors = sensors.dummy(2);
        allSensors   = sensors.mixed(eegSensors, dummySensors);
        
        data = cell(1, 3);
        
        importer = physioset.import.matrix(250, 'Sensors', allSensors);
        
        for i = 1:3,
            
            data{i} = import(importer, rand(10, 50000));
            
            set_bad_sample(data{i}, 50:2500);
            set_bad_channel(data{i}, 1:3);
            
        end
        
        myNode = bss_regr.new('Save', true);
        dataFiles = run(myNode, data{:});
        
        pause(5); % give time for OGE to do its magic
        MAX_TRIES = 100;
        tries = 0;
        while tries < MAX_TRIES && ~exist(dataFiles{3}, 'file'),
            pause(5);
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