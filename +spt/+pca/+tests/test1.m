function [status, MEh] = test1()
% TEST1 - Tests basic PCA functionality

import mperl.file.spec.*;
import spt.pca.*;
import test.simple.*;
import misc.rmdir;
import pset.session;

MEh     = [];

if exist('physioset.physioset', 'class'),
    initialize(13);
    hasP = true;
else
    initialize(9);
    hasP = false;
end

if hasP,
    %% Create a new session
    try
        
        name = 'create new session';
        warning('off', 'session:NewSession');
        session.instance;
        warning('on', 'session:NewSession');
        hashStr = datahash.DataHash(randn(1,100));
        pset.session.subsession(hashStr(1:5));
        ok(true, name);
        
    catch ME
        
        ok(ME, name);
        status = finalize();
        return;
        
    end
end


%% default constructor
try
    
    name = 'constructor';
    config;
    pca;
    ok(true, name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% constructor with config options
try
    
    name = 'construct pca object with Var=0.5';
    myNode = pca('Var', .5);
    
    ok(all(get_config(myNode, 'Var') == [0 .5]), name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% process sample data
try
    
    name = 'process sample data';
    
    X = 10*randn(148, 25000);
    X(40,:) = 10*X(40,:);
    X(10,:) = eps*X(10,:);
    X(20,:) = 0;
    
    obj = learn(pca, X);
    
    ok(numel(selection(obj)) == 146, name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% process physioset
if hasP,
    try
        
        name = 'process physioset';
        
        X = 10*randn(148, 25000);
        X(40,:) = 10*X(40,:);
        X(10,:) = eps*X(1,:);
        X(20,:) = 0;
        
        data = import(physioset.import.matrix, X);
        
        obj = learn(pca, data);
        
        ok(numel(selection(obj)) == 146, name);
        
    catch ME
        
        ok(ME, name);
        MEh = [MEh ME];
        
    end
    
    %% process physioset with selection
    try
        
        name = 'process physioset with selection';
        
        X = 10*randn(148, 25000);
        X(40,:) = 10*X(40,:);
        X(10,:) = eps*X(1,:);
        X(20,:) = 0;
        
        data = import(physioset.import.matrix, X);
        
        obj = learn(pca, select(data, 1:15, 1:10000));
        
        ok(numel(selection(obj)) == 14, name);
        
    catch ME
        
        ok(ME, name);
        MEh = [MEh ME];
        
    end
end


%% aic
try
    
    name = 'criterion aic';
    
    X = 10*randn(15, 15000);
    X(10,:) = eps*X(1,:);
  
    data = X;
    
    learn(pca('Criterion', 'aic'), data);
    
    ok(true, name);
    
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% mdl
try
    
    name = 'criterion mdl';
    
    X = 10*randn(15, 15000);
  
    X(10,:) = eps*X(1,:);
    
    data = X;
    
    learn(pca('Criterion', 'mdl'), data);
    
    ok(true, name);
    
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% mibs
try
    
    name = 'criterion mibs';
    
    X = 10*randn(15, 25000);
    X(10,:) = eps*X(1,:);
   
    data = X;
    
    learn(pca('Criterion', 'mibs'), data);
    
    ok(true, name);
    
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% project/backproject
try
    
    name = 'project/backproject';
    
    X = randn(15, 10000);
   
    data = X;
    
    obj = learn(pca('Var', .9999), data);
    
    data2 = proj(obj, data);
    
    data3 = bproj(obj, data2);
    
    ok(max(abs(data(:) - data3(:))) < 0.1, name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% projmat/bprojmat
try
    
    name = 'projmat/bprojmat';
    
    X = 10*randn(15, 25000);
  
    X(10,:) = eps*X(1,:);
    
    data = X;
  
    obj = learn(pca('Var', .99), data);
    
    W = projmat(obj);
    A = bprojmat(obj);
    
    P = W*A;
    
    ok(abs((rcond(P) - 1)) < 1e-3, name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% set/get method config
try
    
    name = 'set/get method config';
    
    obj = pca;
    
    cfg = get_method_config(obj, 'fprintf', 'ParseDisp');
    
    obj = set_method_config(obj, 'fprintf', 'ParseDisp', false);
    
    cfg2 = get_method_config(obj, 'fprintf', 'ParseDisp');
    ok(cfg{2} & ~cfg2{2}, name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

if hasP,
    %% Cleanup
    try
        
        name = 'cleanup';
        clear data dataCopy;
        rmdir(pset.session.instance.Folder, 's');
        session.clear_subsession();
        ok(true, name);
        
    catch ME
        ok(ME, name);
    end
end


%% Testing summary
status = finalize();