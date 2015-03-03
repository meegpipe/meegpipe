function [status, MEh] = sleep_file()
% SLEEP_FILE - Attempts to process very large sleep file

import mperl.file.spec.*;
import test.simple.*;
import safefid.safefid;
import datahash.DataHash;
import misc.rmdir;

MEh     = [];
initialize(5);

%% Create a new session
try
    name = 'create new session';
    warning('off', 'session:NewSession');
    pset.session.instance;
    warning('on', 'session:NewSession');
    hashStr = DataHash(randn(1,100));
    pset.session.subsession(hashStr(1:5));
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

%% process two huge sleep files via OGE
try
    name = 'process two huge sleep files via OGE';
    if oge.has_oge,
        if somsds.has_somsds,
            files = somsds.link2rec('vici', ...
                'subject', '6', ...
                'modality', 'eeg', ...
                'condition', 'sleep', ...
                'folder', pset.session.instance.Folder);
            if numel(files) < 2,
                ok(NaN, name, ...
                    'The required sleep file could not be retrieved');
            else
                myPipe = create_pipeline([], ...
                    'Queue', [meegpipe.get_config('oge', 'queue') ...
                    '@somerenserver.herseninstituut.knaw.nl']);
               
                dataFiles = run(myPipe, files{:});
                pause(5); % give a lot of time to OGE to do its magic
                MAX_TRIES = 50;
                tries = 0;
                while tries < MAX_TRIES && ~exist(dataFiles{1}, 'file'),
                    pause(1000);
                    tries = tries + 1;
                end
                [~, ~] = system(sprintf('qdel -u %s', misc.get_username));
            end
            ok(true, name);
        else
            ok(NaN, name, 'somsds is not available');
        end
    else
        ok(NaN, name, 'OGE is not available');
    end  
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
            'folder', pset.session.instance.Folder);
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
    rmdir(pset.session.instance.Folder, 's');
    pset.session.clear_subsession();
    ok(true, name);
catch ME
    ok(ME, name);
end

%% Testing summary
status = finalize();


end


function myPipe = create_pipeline(myImporter, varargin)

if nargin < 1 || isempty(myImporter),
    myImporter = physioset.import.mff('Precision', 'single');
end

importNode = meegpipe.node.physioset_import.new(...
    'Importer', myImporter);
filterNode = meegpipe.node.filter.new(...
    'Filter', @(sr) filter.lpfilt('fc', 125/(sr/2)));
decimateNode = meegpipe.node.decimate.new('OutputRate', 250);
myPipe = meegpipe.node.pipeline.new(importNode, ...
    filterNode, ...
    decimateNode, varargin{:});
end