function [status, MEh] = test_generators()
% TEST_GENERATORS - Tests event generators


import physioset.event.*;
import physioset.event.std.*;
import test.simple.*;
import datahash.DataHash;
import pset.session;
import meegpipe.node.*;

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


%% default constructors
try
    
    name = 'default constructors';
    sleep_scores_generator;
    periodic_generator;
    ok(true, name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% sleep_scores_generator
try
    
    name = 'default constructors';
    data = get_real_data;
    
    myPipe = pipeline.new('NodeList', ...
        { ...
        physioset_import.new('Importer', physioset.import.physioset), ...
        ev_gen.sleep_scores ...
        }, 'GenerateReport', false);
    
    data = run(myPipe, data);
    
    ev = get_event(data);
    ok(numel(ev) == 761 & isa(ev, 'physioset.event.std.sleep_score'), name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% Cleanup
try
    
    name = 'cleanup'; 
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

function dataCopy = get_real_data()

import pset.session;
import mperl.file.spec.catfile;
import mperl.file.spec.catdir;

if exist('ssmd_0160_eeg_scores_sleep_1_1.pseth', 'file') > 0,
    data = 'ssmd_0160_eeg_scores_sleep_1_1.pseth';
else
    % Try downloading the file
    url = 'http://kasku.org/data/meegpipe/ssmd_0160_eeg_scores_sleep_1_1.zip';
    unzipDir = catdir(session.instance.Folder, 'ssmd_0160_eeg_scores_sleep_1_1');
    unzip(url, unzipDir);
    data = catfile(unzipDir, 'ssmd_0160_eeg_scores_sleep_1_1.pseth');
end

dataCopy = copy(pset.load(data));

save(dataCopy);

dataCopy = get_hdrfile(dataCopy);

[pathCopy, nameCopy] = fileparts(dataCopy);
[path, name] = fileparts(data);

copyfile(catfile(path, [name '.mat']), ...
    catfile(pathCopy, [nameCopy '.mat']));

end
