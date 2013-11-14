function [status, MEh] = test_thilbert()
% TEST_HILBERT - Tests thilbert criterion

import mperl.file.spec.*;
import pset.selector.*;
import spt.criterion.*;
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
    
    name = 'default and static constructors';
    thilbert.new;
    thilbert.pwl;
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
    
    X(2,:) = .20*X(2,:) + sin(2*pi*(1/5)*(1:size(X,2)));
  
    % Select sparse components
    myFilt = bpfilt('fp', [45 55]/(250/2));
    crit = thilbert.new('MaxCard', 1, 'MinCard', 1, 'Filter', myFilt);
    selected = select(crit, [], X, 250);
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