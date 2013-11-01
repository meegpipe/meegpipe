function [status, MEh] = test1()
% TEST1 - Tests basic node functionality

import mperl.file.spec.*;
import meegpipe.node.bad_channels.*;
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
    MEh = [MEh ME];
    
end


%% default constructor
try
    
    name = 'constructor';
    bad_channels;
    ok(true, name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% constructor with config options
try
    
    name = 'construct bad_channels node with NN=20';
    
    myCrit = criterion.var.var('NN', 20);
    myNode = bad_channels('Criterion', myCrit);
    ok(get_config(get_config(myNode, 'Criterion'), 'NN') == 20, name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% process sample data
try
    
    name = 'process sample data';
    
    data = sample_data;
    
    crit = meegpipe.node.bad_channels.criterion.var.var('MinCard', 3, ...
        'MaxCard', 3);
    dataSel = pset.selector.sensor_class('Class', 'eeg');
    myNode = bad_channels('Criterion', crit, 'DataSelector', dataSel);
    run(myNode, data);
    
    badSel = find(is_bad_channel(data));
    
    ok(numel(badSel) == 3 && all(badSel == [10 20 31]), name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% should reject at most 5
try
    
    name = 'should reject at most 5';
    
    data = sample_data;
    
    crit = meegpipe.node.bad_channels.criterion.var.var(...
        'MaxCard', 5, ...
        'Max', -Inf);
    dataSel = pset.selector.sensor_class('Class', 'eeg');
    myNode = bad_channels('Criterion', crit, 'DataSelector', dataSel);
    run(myNode, data);
    
    badSel = find(is_bad_channel(data));
    
    ok(numel(badSel) == 5, name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end


%% use pre-filtering
try
    
    name = 'use pre-filtering';
    
    X = 10*randn(34, 15000);
    myFilter = filter.hpfilt('fc', .5);
    X(31,:) = 50*X(31,:);
    X(5,:) = 100*filter(myFilter, rand(1, 15000))+X(5,:);
    
    warning('off', 'sensors:InvalidLabel');
    eegSensors = sensors.eeg.from_template('egi256', 'PhysDim', 'uV');
    warning('on', 'sensors:InvalidLabel');
    
    eegSensors   = subset(eegSensors, 1:8:256);
    dummySensors = sensors.dummy(2);
    allSensors   = sensors.mixed(eegSensors, dummySensors);
    
    importer = physioset.import.matrix(100, 'Sensors', allSensors);
    data = import(importer, X);
    
    set_bad_sample(data, 50:2500);
    
    crit = meegpipe.node.bad_channels.criterion.var.var(...
        'MinCard',      1, ...
        'MaxCard',      1, ...
        'Filter',       @(sr) filter.hpfilt('fc', .5));
    dataSel = pset.selector.sensor_class('Class', 'eeg');
    myNode = bad_channels('Criterion', crit, 'DataSelector', dataSel);
    run(myNode, data);
    
    badSel = find(is_bad_channel(data));
    
    ok(numel(badSel) == 1 && all(badSel == 5), name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% save node output
try
    
    name = 'save node output';
    
    X = 10*randn(148, 25000);
    X(40,:) = 10*X(40,:);
    X(10,:) = eps*X(1,:);
    X(20,:) = 0;
    
    warning('off', 'sensors:InvalidLabel');
    eegSensors = sensors.eeg.from_template('egi256', 'PhysDim', 'uV');
    warning('on', 'sensors:InvalidLabel');
    
    eegSensors   = subset(eegSensors, 1:2:256);
    dummySensors = sensors.dummy(20);
    allSensors   = sensors.mixed(eegSensors, dummySensors);
    
    importer = physioset.import.matrix(250, 'Sensors', allSensors);
    data = import(importer, X);
    
    set_bad_sample(data, 50:2500);
    
    filtObj = []; % Don't use a filter or set Normalize=false
    crit = meegpipe.node.bad_channels.criterion.var.var('MinCard', 3, ...
        'MaxCard', 3, 'Filter', filtObj);
    dataSel = pset.selector.sensor_class('Class', 'eeg');
    myNode = bad_channels('Save', true, 'Criterion', crit, ...
        'DataSelector', dataSel);
    
    run(myNode, data);
    
    ok( exist(get_output_filename(myNode, data), 'file')>0 ...
        && all(find(is_bad_channel(data)) ==  [10 20 40]), ...
        name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end


%% process multiple files
try
    
    name = 'process multiple datasets';
    
    data = cell(1, 3);
    eegSensors = sensors.eeg.from_template('egi256', 'PhysDim', 'uV');
    eegSensors = subset(eegSensors, 1:10);
    myImporter = physioset.import.matrix('Sensors', eegSensors);
    for i = 1:3,
        data{i} = import(myImporter, randn(10, 1000));
    end
    myNode = bad_channels('Save', false, 'OGE', false);
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
        eegSensors = sensors.eeg.from_template('egi256', 'PhysDim', 'uV');
        eegSensors = subset(eegSensors, 1:10);
        myImporter = physioset.import.matrix('Sensors', eegSensors);
        for i = 1:3,
            data{i} = import(myImporter, randn(10, 1000));
        end
        
        myNode    = bad_channels('Save', true, 'OGE', true);
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
    MEh = [MEh ME];
end

%% Testing summary
status = finalize();

end

function data = sample_data

X = 10*randn(34, 15000);
X(31,:) = 50*X(31,:);
X(10,:) = eps*X(1,:);
X(20,:) = 0;

warning('off', 'sensors:InvalidLabel');
eegSensors = sensors.eeg.from_template('egi256', 'PhysDim', 'uV');
warning('on', 'sensors:InvalidLabel');

eegSensors   = subset(eegSensors, 1:8:256);
dummySensors = sensors.dummy(2);
allSensors   = sensors.mixed(eegSensors, dummySensors);

importer = physioset.import.matrix(100, 'Sensors', allSensors);
data = import(importer, X);

set_bad_sample(data, 50:2500);

end