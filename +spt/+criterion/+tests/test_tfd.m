function [status, MEh] = test_tfd()
% TEST_TFD - Tests tfd criterion

import mperl.file.spec.*;
import pset.selector.*;
import spt.criterion.tfd.*;
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


%% default and static constructors
try
    
    name = 'default constructor';
    tfd;
    tfd.eog;
    ok(true, name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% test selection
try
    
    name = 'sample selection';

    % Create sample physioset
    X = randn(4, 10000);    
    
    X(2,:) = filter(bpfilt('fp', [4 10]/(250/2)), X(2,:));
  
    % Select sparse components
    selected = select(tfd('MaxCard', 1, 'MinCard', 1), [], X, 250);
    selIdx = find(selected);
    
    % Must be OK   
    ok(numel(selIdx) == 1 && selIdx == 2, name);   
    
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