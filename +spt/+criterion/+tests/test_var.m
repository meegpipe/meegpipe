function [status, MEh] = test_var()
% test_var - Tests var criterion

import mperl.file.spec.*;
import pset.selector.*;
import test.simple.*;
import pset.session;
import misc.rmdir;
import datahash.DataHash;
import filter.bpfilt;
import spt.criterion.var.sample_data;

MEh     = [];

initialize(6);

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


%% defaultconstructors
try
    
    name = 'default constructor';
    spt.criterion.var.var;
    spt.criterion.var.new;
    ok(true, name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% Right construction arguments
try
    
    name = 'construction arguments';
    
    % A string (i.e. a regex)
    spt.criterion.var.new('ChannelSet', 'EEG');
    
    % A cell array of strings
    spt.criterion.var.new('ChannelSet', {'EEG 1','EEG 2'});
    
    % A cell array containing a cell array of strings
    spt.criterion.var.new('ChannelSet', {'EEG 1', {'EEG 2', 'EEG 3'}});
    
    ok( true, name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% Wrong construction arguments
try
    name = 'wrong construction arguments';
    
    try 
        spt.criterion.var.new('ChannelSett', 'a');
    catch ME
        if ~strcmp(ME.identifier, 'MATLAB:noPublicFieldForClass'),
            rethrow(ME);
        end        
    end
    
    try 
        spt.criterion.var.new('ChannelSet', 5);
        spt.criterion.var.new('ChannelSet', {'aa', 5});
        spt.criterion.var.new('ChannelSet', {{'a', 5}, 'b'});
    catch ME
        if strcmp(ME.identifier', 'config:set:ChannelSet:InvalidPropValue')
            rethrow(ME);
        end
    end
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% Sample selection
try
    
    name = 'sample selection';
    
    [data, A] = sample_data();
    
    myCrit = spt.criterion.var.new('ChannelSet', 'EEG \d$', 'MaxCard', 5, ...
        'MinCard', 5);
    
    
    sptObj = learn(spt.bss.efica.new, data);
    sptObj = match_sources(sptObj, A);
    ics = proj(sptObj, data);
    
    selection = select(myCrit, sptObj, ics, [], [], [], data);        
    
    
    ok( selection(end) & ~selection(1), name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% Sample selection without a set of relevant channels
try
    
    name = 'sample selection without a set of relevant channels';
    
    [data, A] = sample_data();
    
    myCrit = spt.criterion.var.new('MaxCard', 5, 'MinCard', 5);
    
    
    sptObj = learn(spt.bss.efica.new, data);
    sptObj = match_sources(sptObj, A);
    ics = proj(sptObj, data);
    
    selection = select(myCrit, sptObj, ics, [], [], [], data);        
    
    
    ok( selection(end) & ~selection(1), name);
    
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

