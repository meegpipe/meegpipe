function [status, MEh] = test_data_selector()
% TEST_DATA_SELECTOR - Tests data_selector criterion for bad channel
% rejection

import mperl.file.spec.*;
import meegpipe.node.*;
import test.simple.*;
import pset.session;
import safefid.safefid;
import datahash.DataHash;
import misc.rmdir;
import oge.has_oge;

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
    MEh = [MEh ME];
    
end


%% constructors
try
    
    name = 'constructors';
    bad_channels.criterion.data_selector.new;
    
    myCrit = bad_channels.criterion.data_selector.new(pset.selector.good_data);
    mySel1 = get_config(myCrit, 'DataSelector');
    myCrit = bad_channels.criterion.data_selector.new(...
        pset.selector.good_data, pset.selector.good_samples);
    mySel2 = get_config(myCrit, 'DataSelector');
    
    
    ok(isa(mySel1, 'pset.selector.good_data') & ...
        isa(mySel2, 'pset.selector.cascade'), name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% simple example
try
    
    name = 'simple example';
   
    mySel = pset.selector.sensor_idx([3 5 9]);
    myCrit = bad_channels.criterion.data_selector.new(...
        pset.selector.good_data, mySel);
    
    data = import(physioset.import.matrix, rand(10, 100));
    
    [idx, rankVal] = find_bad_channels(myCrit, data);

    ok(numel(idx) == 3 & all(sort(idx) == [3 5 9]) & ...
        numel(rankVal) == 10 & all(rankVal([3 5 9]) == 1) & ...
        all(rankVal(setdiff(1:10, [3 5 9])) == 0) & ...
        size(data, 1) == 10, name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end


%% Cleanup
try
    
    name = 'cleanup';
    clear data dataCopy;
    rmdir(session.instance.Folder, 's');
    session.clear_subsession();
    ok(true, name);
    
catch ME
    ok(ME, name);
    MEh = [MEh ME];
end

%% Testing summary
status = finalize();