function [status, MEh] = sleep_file()
% SLEEP_FILE - Attempts to process very large sleep file

import mperl.file.spec.*;
import test.simple.*;
import pset.session;
import safefid.safefid;
import datahash.DataHash;
import misc.rmdir;

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

%% process tiny sample data file
try
    name = 'process tiny sample data file';
    importNode = meegpipe.node.physioset_import.new(...
        'Importer', physioset.import.matrix);
    filterNode = meegpipe.node.filter.new(...
        'Filter', @(sr) filter.lpfilt('fc', 20/(sr/2)));
    myNode = meegpipe.node.pipeline.new(importNode, filterNode);
    
    X      = randn(10, 10000);
    data   = run(myNode, X);
    ok(all(size(data) == size(X)), name);
catch ME
    ok(ME, name);
    MEh = [MEh ME];
end


%% process huge sleep file (will take very long...)
try
    name = 'process huge sleep file (will take very long...)';
    if somsds.has_somsds,
        files = somsds.link2rec('vici', ...
            'subject', '6', ...
            'modality', 'eeg', ...
            'condition', 'sleep', ...
            'folder', session.instance.Folder);
        if isempty(files),
            ok(NaN, name, ...
                'The required sleep file could not be retrieved');
        else
            importNode = meegpipe.node.physioset_import.new(...
                'Importer', physioset.import.mff);
            filterNode = meegpipe.node.filter.new(...
                'Filter', @(sr) filter.lpfilt('fc', 20/(sr/2)));
            myNode = meegpipe.node.pipeline.new(importNode, filterNode);
            
            data   = run(myNode, files{1});
            ok(true, name);
        end
    else
        ok(NaN, name, 'somsds is not installed in this system')
    end
catch ME
    ok(ME, name);
    MEh = [MEh ME];
end


%% Cleanup
try
    name = 'cleanup';
    clear data ans importNode filterNode;
    rmdir(session.instance.Folder, 's');
    session.clear_subsession();
    ok(true, name);
catch ME
    ok(ME, name);
end

%% Testing summary
status = finalize();