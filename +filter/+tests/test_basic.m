function [status, MEh] = test_basic()
% TEST_BASIC - Tests basic package functionality

import mperl.file.spec.*;
import filter.*;
import test.simple.*;

MEh     = [];

initialize(5);

%% Default constructors
try
    
    name = 'default constructors';
    adaptfilt;
    ba;
    bpfilt;
    cascade;
    hpfilt;
    mlag_regr;
    sbfilt;    
    ok(true, name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% Filtering with lpfilt
try
    
    name = 'filtering with lpfilt';
    filter(filter.lpfilt('fc', 0.5), randn(5,1000));
    ok(true, name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% Filtering with hpfilt
try
    
    name = 'filtering with hpfilt';
    filter(filter.hpfilt('fc', 0.5), randn(5,1000));
    ok(true, name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];

end

%% Filtering with bpfilt
try
    
    name = 'filtering with bpfilt';
    filter(filter.bpfilt('fp', [0.1 0.5]), randn(5,1000));
    ok(true, name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% Filtering with sbfilt
try
    
    name = 'filtering with spfilt';
    filter(filter.sbfilt('fstop', [0.1 0.5]), randn(5,1000));
    ok(true, name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end



%% Testing summary
status = finalize();