function [status, MEh] = test_basic()
% TEST_BASIC - Tests basic package functionality

import mperl.file.spec.*;
import filter.*;
import test.simple.*;

MEh     = [];

initialize(8);

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
    filter(filter.lpfilt('fc', 0.5), randn(5, 10000));
    ok(true, name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% Ensure NbChansPerChunk does not affect the filtering result
try
    
    name = 'ensure NbChansPerChunk does not affect the filtering result';
    x = randn(10,10000);
    y1 = filter(filter.lpfilt('fc', 0.5, 'NbChansPerChunk', 1), x);
    y2 = filter(filter.lpfilt('fc', 0.5, 'NbChansPerChunk', 3), x);
    ok(all(y1(:) == y2(:)), name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% Filtering with hpfilt
try
    
    name = 'filtering with hpfilt';
    filter(filter.hpfilt('fc', 0.5), randn(5, 10000));
    ok(true, name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];

end

%% Filtering with bpfilt
try
    
    name = 'filtering with bpfilt';
    filter(filter.bpfilt('fp', [0.1 0.5]), randn(5, 10000));
    ok(true, name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% Filtering with sbfilt
try
    
    name = 'filtering with spfilt';
    filter(filter.sbfilt('fstop', [0.1 0.5]), randn(5, 10000));
    ok(true, name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% filter() with cascade filter
try
    name = 'filter() with cascade filter';
    myFilt1 = filter.lpfilt('fc', 0.1);
    myFilt2 = filter.hpfilt('fc', 0.01);
    myFilt  = filter.cascade(myFilt1, myFilt2);
    X = randn(5, 10000);
    Y1 = filter(myFilt2, filter(myFilt1, X));
    Y2 = filter(myFilt, X);
    ok(max(abs(Y1(2,:)-Y2(2,:))) < 1e-6, name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% filtfilt() with cascade filter
try
    name = 'filtfilt() with cascade filter';
    myFilt1 = filter.lpfilt('fc', 0.1);
    myFilt2 = filter.hpfilt('fc', 0.01);
    myFilt  = filter.cascade(myFilt1, myFilt2);
    X = randn(5, 10000);
    Y1 = filtfilt(myFilt2, filtfilt(myFilt1, X));
    Y2 = filtfilt(myFilt, X);
    ok(max(abs(Y1(2,:)-Y2(2,:))) < 1e-6, name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end



%% Testing summary
status = finalize();