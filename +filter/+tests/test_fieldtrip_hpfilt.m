function [status, MEh] = test_fieldtrip_hpfilt()
% TEST_FIELDTRIP_HPFILT - Tests fieldtrip_hpfilt filter
import mperl.file.spec.*;
import filter.*;
import test.simple.*;
import pset.session;
import datahash.DataHash;

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

%% constructor
try
    
    name = 'constructor';
    filter.fieldtrip_hpfilt;
    obj  = filter.fieldtrip_hpfilt(20, 'Verbose', false);
    obj2 = filter.fieldtrip_hpfilt('Fc', 20);
    ok(...
        isa(obj, 'filter.fieldtrip_hpfilt') & ~is_verbose(obj) & ...
        all(obj2.Fc == 20) & all(obj.Fc == 20), ...
        name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end



%% sample filtering
try
    
    name = 'sample filtering';
    X = randn(5, 1000);
    
    X = filter(filter.lpfilt('fc', 40/125), X);
    
    N = filter(filter.fieldtrip_hpfilt(50, 'SamplingRate', 250), ...
        0.1*randn(5, 1000));   
    
    data = import(physioset.import.matrix('SamplingRate', 250), X+N);
    
    snr0 = 0;
    for i = 1:size(X, 1)
        snr0 = snr0 + var(N(i,:))/var(X(i,:));
    end
    
    myFilt = filter.fieldtrip_hpfilt('Fc', 50);
    filter(myFilt, data);
    
    snr1 = 0;
    for i = 1:size(X, 1)
        snr1 = snr1 + var(N(i,:))/var(data(i,:) - N(i,:));
    end
    ok(snr1 > 5*snr0, name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% Cleanup
try

    name = 'cleanup';   
    clear data dataCopy ans myCfg myNode;
    rmdir(session.instance.Folder, 's');
    session.clear_subsession();
    ok(true, name);

catch ME
    ok(ME, name);
end



%% Testing summary
status = finalize();