function [status, MEh] = test_sgini()
% TEST_sgini - Tests sgini criterion

import mperl.file.spec.*;
import pset.selector.*;
import spt.criterion.sgini;
import test.simple.*;
import pset.session;
import misc.rmdir;
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


%% default and static constructors
try
    
    name = 'default constructor';
    sgini.new;
    sgini.emg;
    ok(true, name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% test selection
try
    
    name = 'sample selections';
  
    % Create sample physioset
    X = [randn(3, 50000);rand(1,50000)];    
  
    bssObj = learn(spt.bss.jade, X);
    
    W = projmat(bssObj);
    
    [~, idx] = max(abs(corr(W', [0 0 0 1]')));    
    
    % Select sparse components
    crit = sgini('MaxCard', 1, 'MinCard', 1);
    selected = select(crit, bssObj);
    selIdx = find(selected);
    
    % Must be OK   
    ok(numel(selIdx) == 1 && selIdx == idx, name);   
    
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