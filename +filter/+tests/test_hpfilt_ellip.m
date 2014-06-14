function [status, MEh] = test_hpfilt_ellip()
% TEST_HPFILT_ELLIP - Tests hpfilt_ellip filter
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
    filter.hpfilt_ellip;
    obj  = filter.hpfilt_ellip(0.5, 'Verbose', false);
    obj2 = filter.hpfilt_ellip('Fc', 0.5);
    ok(...
        isa(obj, 'filter.hpfilt_ellip') && ~is_verbose(obj) && ...
        all(obj2.Fc == 0.5) && all(obj.Fc == 0.5), ...
        name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% high-pass filter
try
    
    name = 'high-pass filter';
    X = randn(5, 1000);
    
    X = filter(filter.lpfilt('fc', 10/(250/2)), X);
    
    N = 0.1*randn(5, 1000);   
    
    data = import(physioset.import.matrix('SamplingRate', 250), X+N);
    
    snr0 = 0;
    for i = 1:size(X, 1)
        snr0 = snr0 + var(N(i,:))/var(X(i,:));
    end
    
    myFilt = filter.hpfilt_ellip('Fc', 10/(data.SamplingRate/2));
    filter(myFilt, data);
    
    snr1 = 0;
    for i = 1:size(X, 1)
        snr1 = snr1 + var(N(i,:))/var(data(i,:) - N(i,:));
    end
    ok(snr1 > 3*snr0, name);
    
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