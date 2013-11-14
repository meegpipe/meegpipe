function [status, MEh] = test_xcorr()
% TEST_XCORR - Tests xcorr criterion

import mperl.file.spec.*;
import pset.selector.*;
import spt.criterion.xcorr.*;
import test.simple.*;
import pset.session;
import misc.rmdir;
import datahash.DataHash;

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
    status = finalize();
    return;
    
end


%% default and static constructors
try
    
    name = 'default constructor';
    xcorr;
    xcorr.bcg;
    ok(true, name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% construction arguments
try
    
    name = 'construction arguments';
    obj = xcorr('Selector', sensor_class('Type', 'CW'), 'Min', 0.5, ...
        'SummaryFunc', @(x) x);
    
    minVal = get_config(obj, 'Min');
    fh     = get_config(obj, 'SummaryFunc');    
    
    ok( minVal == .5 && numel(fh(1:10)) == 10 && all(fh(1:10)==1:10), name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% test selection
try
    
    name = 'sensor_class (1)';
    % Create three independent sensor groups
    % (never mind about sensor labels)
    sg1 = sensors.dummy(5);
    sg2 = sensors.physiology('Label', {'ECG 1', 'ECG 2'});
    sg3 = sensors.eeg.dummy(10);
    
    % Put them together into a mixed sensor array
    mySensors = sensors.mixed(sg1, sg2, sg3);
    
    % Create sample physioset
    X = randn(17, 1000);
    
    X([1 3],:) = 0.7*X([1 3],:) + 0.3*repmat(X(7,:),2, 1);
    
    data = import(physioset.import.matrix(250, 'Sensors', mySensors), X);
    
    % Select only those components correlating with the ECG channels   
    myCrit = xcorr.bcg('MinCard', 4, 'MaxCard', 4);
    selected = select(myCrit, [], X, [], [], [], data);
    selIdx = find(selected);
    
    % Must be OK   
    ok(numel(selIdx) == 4 && all(selIdx == [ 1 3 6 7]), name);   
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end



%% Cleanup
try
    
    name = 'cleanup';
    clear data X;
    rmdir(session.instance.Folder, 's');
    session.clear_subsession();
    ok(true, name);
    
catch ME
    ok(ME, name);
end

%% Testing summary
status = finalize();