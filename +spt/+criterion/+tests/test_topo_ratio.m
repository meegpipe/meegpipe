function [status, MEh] = test_topo_ratio()
% test_topo_ratio - Tests topo_ratio criterion

import mperl.file.spec.*;
import pset.selector.*;
import test.simple.*;
import pset.session;
import misc.rmdir;
import datahash.DataHash;
import filter.bpfilt;
import spt.criterion.topo_ratio.sample_data;

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
    spt.criterion.topo_ratio.topo_ratio;
    spt.criterion.topo_ratio.new;
    ok(true, name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% Right construction arguments
try
    
    name = 'construction arguments';
    
    % A string (i.e. a regex)
    spt.criterion.topo_ratio.new('SensorsDen', 'EEG\s+\d+');
    
    % A cell array of strings
    spt.criterion.topo_ratio.new('SensorsDen', {'EEG 1','EEG 2'});
    
    ok( true, name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% Wrong construction arguments
try
    name = 'wrong construction arguments';
    
    try 
        spt.criterion.topo_ratio.new('SensorsDendd', 'a');
    catch ME
        if ~strcmp(ME.identifier, 'MATLAB:noPublicFieldForClass'),
            rethrow(ME);
        end        
    end
    
    try 
        spt.criterion.topo_ratio.new('SensorsDen', 5);
        spt.criterion.topo_ratio.new('SensorsDen', {'aa', 5});
        spt.criterion.topo_ratio.new('SensorsDen', {{'a', 5}, 'b'});
    catch ME
        if strcmp(ME.identifier', 'config:set:SensorsDen:InvalidPropValue')
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
    
    myCrit = spt.criterion.topo_ratio.new(...
        'SensorsNumLeft', {'EEG 1', 'EEG 2'}, ...
        'MaxCard', 2, ...
        'MinCard', 2);

    sptObj = learn(spt.bss.efica.new, data);
    sptObj = match_sources(sptObj, A);
    ics = proj(sptObj, data);
    
    selection = select(myCrit, sptObj, ics, [], [], [], data);        

    idx = find(selection);
    
    ok( numel(idx) == 2 && all(idx == [1 2]), name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% empty channel selection
try
    
    name = 'empty channel selection';
    
    [data, A] = sample_data();
    
    myCrit = spt.criterion.topo_ratio.new(...
        'SensorsNumLeft', 'XXXX (1|2)$', ...
        'MaxCard', 2, ...
        'MinCard', 2);

    sptObj = learn(spt.bss.efica.new, data);
    sptObj = match_sources(sptObj, A);
    ics = proj(sptObj, data);
    
    warning('off', 'topo_ratio:EmptyNumSet');
    selection = select(myCrit, sptObj, ics, [], [], [], data);        
    warning('on', 'topo_ratio:EmptyNumSet');
    
    [~, id] = lastwarn;
    idx = find(selection);
    
    ok( numel(idx) == 2 && strcmp(id, 'topo_ratio:EmptyNumSet'), name);
    
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

