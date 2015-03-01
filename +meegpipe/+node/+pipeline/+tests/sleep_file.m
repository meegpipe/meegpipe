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
    X      = randn(10, 40000);
    myImporter = physioset.import.matrix('SamplingRate', 1000);
    myPipe = create_pipeline(myImporter);
    data   = run(myPipe, X);
    ok(size(data,2) == 10000, name);
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
            myPipe = create_pipeline();
            data   = run(myPipe, files{1});
            ok(size(data,1) > 20 && size(data,2) > 100000, name);
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


end


function myPipe = create_pipeline(importer)

if nargin < 1,
    importer = physioset.import.mff('Precision', 'single');
end

importNode = meegpipe.node.physioset_import.new(...
    'Importer', importer);
filterNode = meegpipe.node.filter.new(...
    'Filter', @(sr) filter.lpfilt('fc', 125/(sr/2)));
decimateNode = meegpipe.node.decimate.new('OutputRate', 250);
myPipe = meegpipe.node.pipeline.new(importNode, ...
    filterNode, ...
    decimateNode);
end