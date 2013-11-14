function [status, MEh] = test_channel_stat()
% test_channel_stat - Tests channel_stat feature

import mperl.file.spec.*;
import pset.selector.*;
import test.simple.*;
import pset.session;
import misc.rmdir;
import datahash.DataHash;
import filter.bpfilt;

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
    status = finalize();
    return;
    
end


%% default constructors
try
    
    name = 'default constructor';
    spt.feature.channel_stat;    
    ok(true, name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% Sample feature extraction
try
    
    name = 'Sample feature extraction';
    
    [data, A] = sample_data();
    
    myFeat = spt.feature.channel_stat(...
        'TargetSelector', sensor_class('Class', 'EEG'), ...
        'AggregatingStat', @(x) max(x));
    
    
    sptObj = learn(spt.bss.efica, data);
    sptObj = match_sources(sptObj, A);
    ics = proj(sptObj, data);
    
    featVal = extract_feature(myFeat, sptObj, ics);        
    
    
    ok( all(diff(featVal)<0), name);
    
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

end


function [data, A] = sample_data()


X = rand(5, 1000);

sensObj = sensors.eeg.dummy(5);

A = misc.unit_norm(rand(5));

for i = 1:size(A,2),
    A(1,i) = 10*i;
end

data = import(physioset.import.matrix('Sensors', sensObj), A*X);


end