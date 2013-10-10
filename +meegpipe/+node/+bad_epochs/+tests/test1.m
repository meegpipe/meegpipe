function [status, MEh] = test1()
% TEST1 - Tests basic node functionality

import mperl.file.spec.*;
import meegpipe.node.bad_epochs.*;
import test.simple.*;
import pset.session;
import safefid.safefid;
import datahash.DataHash;
import misc.rmdir;
import oge.has_oge;
import physioset.event.event;
import physioset.event.class_selector;

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
    bad_epochs;
    ok(true, name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% constructor with config options
try
    
    name = 'construct bad_epochs node with using a custom config';
    mySel  = class_selector('Type', 'myevent');
    
    crit = criterion.stat.stat(...
        'Statistic1',    @(x) max(abs(x)), ...
        'Statistic2',    @(x) max(x), ...
        'Percentile',    [5 95]);
    
    myNode = bad_epochs(...
        'Criterion',     crit, ...
        'EventSelector', mySel, ...    
        'Save',          true);
    
    perc = get_config(get_config(myNode, 'Criterion'), 'Percentile');
    ok(~isempty(get_config(myNode, 'Criterion')) & all(perc ==[5 95]), name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% process sample data
try
    
    name = 'process sample data';

    data = my_sample_data();
     
    myNode = my_sample_node();
    
    run(myNode, data);
    
    ok(numel(find(is_bad_sample(data))) == 250, name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% minmax
try
    
    name = 'minmax';

    data = my_sample_data();
     
    mySel  = class_selector('Type', 'myevent');
    myNode = minmax(-10, 10, 'EventSelector', mySel);
    
    run(myNode, data);
    
    ok(numel(find(is_bad_sample(data))) == 900, name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% process multiple files
try
    
    name = 'process multiple datasets';
    
    data = cell(1, 2);
    for i = 1:2,
        data{i} = my_sample_data();
    end
    myNode = my_sample_node('Save', false, 'OGE', false);
    run(myNode, data{:});
    ok(true, name);
    
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end


%% save node output
try
    
    name = 'save node output';
    
    data = my_sample_data();
    
    myNode = my_sample_node('Save', true);

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
        
        myNode    = my_sample_node('Save', true, 'OGE', true);
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
function [data, bad] = my_sample_data()
import physioset.event.event;

X = sin(2*pi*(1/100)*(0:199));
X = rand(10,1)*X;
X = repmat(X, [1 1 50]);
X = X + 0.25*rand(size(X));

X(1, 50, 10) = 20;
X(1, 30, 20) = -30;
bad = [10 20];

sens = sensors.eeg.from_template('egi256');
sens = subset(sens, ceil(linspace(1, nb_sensors(sens), 10)));
data = import(physioset.import.matrix('Sensors', sens), X);

pos = get(get_event(data), 'Sample');
off = ceil(0.1*data.SamplingRate);
ev = event(pos + off, 'Type', 'myevent');
add_event(data, ev);

end

function myNode = my_sample_node(varargin)

import physioset.event.class_selector;
import meegpipe.node.bad_epochs.bad_epochs;
import meegpipe.node.bad_epochs.criterion.stat.stat;

mySel  = class_selector('Type', 'myevent');
crit   = stat(...
    'Statistic1',    @(x) max(abs(x)), ...
    'Statistic2',    @(x) max(x), ...
    'Percentile',    [0 100], ...
    'Max',           15);


myNode = bad_epochs(...
    'Criterion',     crit, ...
    'Duration',      0.5, ...
    'Offset',        -0.1, ...
    'EventSelector', mySel, ...
    'Save',          true);


end