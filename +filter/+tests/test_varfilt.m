function [status, MEh] = test_varfilt
% TEST_VARFILT - Tests varfilt filter

import test.simple.ok;
import pset.session;
import datahash.DataHash;
import misc.rmdir;
import mperl.file.spec.*;


MEh = [];

test.simple.initialize(4);

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

%% Constructor
try
    
    name = 'constructor';
    
    myFilt = filter.varfilt;
    
    cond = isa(myFilt, 'filter.varfilt') & isa(myFilt, 'filter.dfilt');
    
    myFilt = filter.varfilt(...
        'VAR',      var.arfit('MinOrder', 5, 'MaxOrder', 15), ...
        'ForceAR',  true, ...
        'Name',     'myfilter');
    
    cond = cond & ...
        strcmp(get_name(myFilt), 'myfilter') & ...
        isa(myFilt.VAR, 'var.arfit') & ...
        myFilt.VAR.MinOrder == 5 & ...
        myFilt.VAR.MaxOrder == 15 & ...
        myFilt.ForceAR;
    
    ok(cond, name);
    
catch ME
    
    ok(ME, name);
    status = finalize();
    return;
    
end

%% filter random data
try
    
    name = 'filter random data';
    
    myFilt = filter.varfilt;
    
    data = randn(4,1000);
    dataF = filter(myFilt, data);
    
    ok(cond, name);
    
catch ME
    
    ok(ME, name);
    status = finalize();
    return;
    
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
status = test.simple.finalize();


end