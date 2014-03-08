function [status, MEh] = test_user_defined()
% TEST_USER_DEFINED - User-defined runtime params

import mperl.file.spec.*;
import test.simple.*;
import pset.session;
import safefid.safefid;
import datahash.DataHash;
import misc.rmdir;
import oge.has_oge;
import misc.get_username;

MEh     = [];

initialize(5);

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

%% invalidate user selections
try
    
    name = 'invalidate user selections';
    
    myPipe = sample_pipe();
    
    X      = randn(5, 1000);
    data   = run(myPipe, X);
    
    condition = (rank(cov(data)) == 3);
    
    if condition,
        spcSel = get_spcs_selection(myPipe, X);
        badChanSel = get_bad_channel_selection(myPipe, X);
        
        % Change bad channel and spcs selections and re-run
        clear data myPipe;
        myPipe = sample_pipe(true);
        spcSel = setdiff(1:5, spcSel);
        badChanSel = setdiff(1:size(X,1), badChanSel);
        set_bad_channel_selection(myPipe, X, badChanSel);
        set_spcs_selection(myPipe, X, spcSel);
        run(myPipe, X);
        newSpcSel = get_spcs_selection(myPipe, X);
        % It should have ignored the BSS component selection since the bad
        % channels node configuration changed
        condition = condition & numel(newSpcSel) == 2;
        
    end
    
    ok(condition, name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end


%% bad channels user selection
try
    
    name = 'bad channels user selection';
    
    myPipe = sample_pipe();
    
    X      = randn(5, 1000);
    data   = run(myPipe, X);
    
    condition = (rank(cov(data)) == 3);
    
    if condition,
        badChanSel = get_bad_channel_selection(myPipe, X);
        % re-run again and ensure that the same channels are rejected
        clear data myPipe;
        myPipe = sample_pipe();
        run(myPipe, X);
        newBadChanSel = get_bad_channel_selection(myPipe, X);
        condition = condition & all(badChanSel == newBadChanSel);
        if condition
            % Change configuration and re-run
            clear data myPipe;
            myPipe = sample_pipe();
            badChanSel = setdiff(1:size(X,1), badChanSel);
            set_bad_channel_selection(myPipe, X, badChanSel);
            run(myPipe, X);
            newBadChanSel = get_bad_channel_selection(myPipe, X);
            condition = condition & all(badChanSel(:) == newBadChanSel(:));  
        end
    end
    
    ok(condition, name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end


%% spcs user selection
try
    
    name = 'spcs user selection';
    
    myPipe = sample_pipe();
    
    X      = randn(5, 1000);
    data   = run(myPipe, X);
    
    condition = (rank(cov(data)) == 3);
    
    if condition,
        spcSel = get_spcs_selection(myPipe, X);
        % re-run again and ensure that the same channels are rejected
        clear data myPipe;
        myPipe = sample_pipe();
        run(myPipe, X);
        newSpcSel = get_spcs_selection(myPipe, X);
        condition = condition & all(spcSel == newSpcSel);
        if condition
            % Change configuration and re-run
            clear data myPipe;
            myPipe = sample_pipe();
            spcSel = setdiff(1:5, spcSel);
            set_spcs_selection(myPipe, X, spcSel);
            run(myPipe, X);
            newSpcSel = get_spcs_selection(myPipe, X);
            condition = condition & all(spcSel(:) == newSpcSel(:));  
        end
    end
    
    ok(condition, name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end




%% Cleanup
try
    
    name = 'cleanup';
    % just in case
    [~, ~] = system(sprintf('qdel -u %s', get_username));
    
    pause(5); % Some time for the jobs to be killed
    clear data dataCopy ans myCfg myNode;
    rmdir(session.instance.Folder, 's');
    session.clear_subsession();
    ok(true, name);
    
catch ME
    ok(ME, name);
end

%% Testing summary
status = finalize();

end


function myPipe = sample_pipe(flag)

import meegpipe.node.*;
if nargin < 1, flag = false; end

myCrit = bad_channels.criterion.var.var('MinCard', 2, 'MaxCard', 2, ...
    'Max', 1000);

if flag,
    myBadChan = ...
        bad_channels.new('Criterion', myCrit, 'GenerateReport', false);
else
    myBadChan = ...
        bad_channels.new('Criterion', myCrit, 'GenerateReport', false);    
end

myBSS = bss.eog('MinCard', 2, 'MaxCard', 2, 'GenerateReport', false, ...
    'RegrFilter', []);
myPipe = pipeline.new(...
    physioset_import.new('Importer', physioset.import.matrix), ...
    copy.new, ...
    myBadChan, ...
    myBSS);

end

function badChanSel = get_bad_channel_selection(myPipe, X)

import mperl.file.spec.*;
import mperl.config.inifiles.inifile;

nodeList = get_config(myPipe, 'NodeList');
badChansCfgFile = catfile(get_full_dir(myPipe, X), ...
    get_name(nodeList{3}), [get_name(nodeList{3}) '.ini']);
cfgBadChans = inifile(badChansCfgFile);
badChanSel = val(cfgBadChans, 'channels', 'reject', true);
if isempty(badChanSel), return; end
badChanSel = cellfun(@(x) str2double(x), badChanSel);

end


function badChanSel = set_bad_channel_selection(myPipe, X, sel)

import mperl.file.spec.*;
import mperl.config.inifiles.inifile;

nodeList = get_config(myPipe, 'NodeList');
badChansCfgFile = catfile(get_full_dir(myPipe, X), ...
    get_name(nodeList{3}), [get_name(nodeList{3}) '.ini']);
cfgBadChans = inifile(badChansCfgFile);
sel = arrayfun(@(x) num2str(x), sel, 'UniformOutput', false);
badChanSel = setval(cfgBadChans, 'channels', 'reject', sel{:});

end

function spcSel = get_spcs_selection(myPipe, X)

import mperl.file.spec.*;
import mperl.config.inifiles.inifile;

nodeList = get_config(myPipe, 'NodeList');
cfgFile = catfile(get_full_dir(myPipe, X), ...
    get_name(nodeList{4}), [get_name(nodeList{4}) '.ini']);
cfg = inifile(cfgFile);
spcSel = val(cfg, 'bss', 'selection', true);
if isempty(spcSel), return; end
spcSel = cellfun(@(x) str2double(x), spcSel);

end

function spcSel = set_spcs_selection(myPipe, X, sel)

import mperl.file.spec.*;
import mperl.config.inifiles.inifile;

nodeList = get_config(myPipe, 'NodeList');
cfgFile = catfile(get_full_dir(myPipe, X), ...
    get_name(nodeList{4}), [get_name(nodeList{4}) '.ini']);
cfg = inifile(cfgFile);
sel = num2cell(sel);
spcSel = setval(cfg, 'bss', 'selection', sel{:});

end