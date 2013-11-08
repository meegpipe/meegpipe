function [status, MEh] = test_basic()
% test_basic - Tests basic node functionality

import mperl.file.spec.*;
import meegpipe.node.spectra.*;
import test.simple.*;
import pset.session;
import safefid.safefid;
import datahash.DataHash;
import misc.rmdir;
import oge.has_oge;
import physioset.event.event;
import physioset.event.class_selector;
import meegpipe.aggregate;

MEh     = [];

initialize(9);

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
    spectra;
    ok(true, name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% constructor with config options
try
    
    name = 'construct spectra node with using a custom config';
    mySel  = class_selector('Type', 'myevent');
    myNode = spectra(...
        'EventSelector', mySel, ...
        'Duration',      5, ...
        'Offset',        -0.1);
    ok(abs(get_config(myNode, 'Duration') - 5)<eps, name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% process sample data
try
    
    name = 'process sample data';
    
    data = my_sample_data();
    
    set_bad_sample(data, 1000:5000);
    
    roi = eeg_bands;
    roi('dummy') = {[1 4], [0 100]};
    mySel  = class_selector('Type', 'myevent');
    myNode = spectra('EventSelector', mySel, 'ROI', roi);
    
    run(myNode, data);
    
    feat  = get_spectra_features(myNode);
    
    ok( feat{1}('dummy') > 2*feat{1}('alpha'), name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% multiple channel sets
try
    
    name = 'multiple channel sets';
    
    data = my_sample_data();
    
    set_bad_sample(data, 1000:5000);
    
    roi = eeg_bands;
    roi('dummy') = {[1 4], [0 100]};
    mySel  = class_selector('Type', 'myevent');
    myNode = spectra('EventSelector', mySel, 'ROI', roi, ...
        'Channels', {'.+', 'EEG 1', 'EEG 2'});
    
    run(myNode, data);
    
    feat  = get_spectra_features(myNode);
    
    ok( feat{1}('dummy') > 5*feat{1}('alpha') && ...
        feat{2}('dummy') > 5*feat{2}('alpha') && ...
        feat{3}('dummy') > 5*feat{3}('alpha'), name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end


%% aggregate spectral features from multiple datasets
try
    
    name = 'aggregate spectral features from multiple datasets';
    
    data = cell(1, 2);
    for i = 1:2,
        data{i} = my_sample_data();
    end
    mySel  = class_selector('Type', 'myevent');
    myNode = spectra('EventSelector', mySel, 'Save', false, 'OGE', false);
    run(myNode, data{:});    
  
    transRegex = '(?<date>.{14})_(?<hash>.{5}).+';
    
    fName = aggregate(data, 'features.txt', 'features_all.txt', ...
        transRegex, [], false, false);   
    
    ok(exist(fName, 'file')>0, name);
    
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end


%% save node output
try
    
    name = 'save node output';
    
    data = my_sample_data();
    
    mySel  = class_selector('Type', 'myevent');
    myNode = spectra('EventSelector', mySel, 'Save', true, 'OGE', false);
    
    run(myNode, data);
    
    ok(exist(get_output_filename(myNode, data), 'file')>0, name);
    
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
            data{i} = my_sample_data();
        end
        
        mySel  = class_selector('Type', 'myevent');
        myNode = spectra('EventSelector', mySel, 'Save', true, 'OGE', true);
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

end

%% Helper functions
function data = my_sample_data()
import physioset.event.event;

X = sin(2*pi*(1/100)*(0:1999));
X = rand(10,1)*X;
X = repmat(X, [1 1 50]);
X = X + 0.25*randn(size(X));
sens = sensors.eeg.from_template('egi256');
sens = subset(sens, ceil(linspace(1, nb_sensors(sens), 10)));
data = import(physioset.import.matrix('Sensors', sens), X);

pos = get(get_event(data), 'Sample');
off = ceil(0.1*data.SamplingRate);
ev = event(pos + off, 'Type', 'myevent', 'Duration', 3000);
add_event(data, ev);

end

