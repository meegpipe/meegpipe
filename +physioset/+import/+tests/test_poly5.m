function [status, MEh] = test_poly5()
% TEST_POLY5 - Test importer for TMSi's .Poly5/.events.csv format

import mperl.file.spec.*;
import physioset.import.poly5;
import test.simple.*;
import pset.session;
import safefid.safefid;
import datahash.DataHash;
import misc.rmdir;
import misc.set_warning_status;

% The sample data file to be used for testing
DATA_FILE = '20140205_112958.DummyData.Poly5';
DATA_FILE_2 = '20131125_130803.DATA.Poly5';
DATA_URL = 'http://kasku.org/data/meegpipe/';
WARN_IDS = { 'sensors:MissingPhysDim', 'sensors:MissingPhysDim' };

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


%% default constructor
try
    
    name = 'constructor';
    poly5;
    ok(true, name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% import sample data
try
    
    name = 'import sample data file';
    folder = session.instance.Folder;
    
    [fPath, fName, fExt] = fileparts(DATA_FILE);
    evFile = [fPath fName '.events.csv'];
    evFileCopy = catfile(folder, [fName '.events.csv']);
    dataFileCopy = catfile(folder, [fName fExt]);
    if exist(DATA_FILE, 'file'),
        copyfile(DATA_FILE, dataFileCopy);
        copyfile(evFile, evFileCopy);
    else
        urlwrite([DATA_URL fName fExt], dataFileCopy);
        urlwrite([DATA_URL fName '.events.csv'], evFileCopy);
    end
    stat = set_warning_status(WARN_IDS, 'off');
    data = import(poly5, dataFileCopy);
    set_warning_status(WARN_IDS, stat);
    
    ok(all(size(data) == [3 6000]) & numel(get_event(data)) == 6, name);
    
    clear data;
    
    
catch ME
    
    ids = { 'sensors:MissingPhysDim', 'sensors:MissingPhysDim' };
    set_warning_status(ids, 'on');
    clear data;
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% import another sample data
try
    
    name = 'import another sample data file';
    
    folder = session.instance.Folder;
    
    [fPath, fName, fExt] = fileparts(DATA_FILE_2);
    evFile = [fPath fName '.events.csv'];
    evFileCopy = catfile(folder, [fName '.events.csv']);
    dataFileCopy = catfile(folder, [fName fExt]);
    if exist(DATA_FILE_2, 'file'),
        copyfile(DATA_FILE_2, dataFileCopy);
        copyfile(evFile, evFileCopy);
    else
        urlwrite([DATA_URL fName fExt], dataFileCopy);
        urlwrite([DATA_URL fName '.events.csv'], evFileCopy);
    end
    stat = set_warning_status(WARN_IDS, 'off');
    data = import(poly5, dataFileCopy);
    set_warning_status(WARN_IDS, stat);
    
    ok(all(size(data) == [37 2759240]) & numel(get_event(data)) == 0, name);
    
    clear data;
    
    
catch ME
    
    set_warning_status(WARN_IDS, 'on');
    clear data;
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% specify file name
try
    
    name = 'specify file name';
    
    folder = session.instance.Folder;
    
    [fPath, fName, fExt] = fileparts(DATA_FILE);
    evFile = [fPath fName '.events.csv'];
    evFileCopy = catfile(folder, [fName '.events.csv']);
    dataFileCopy = catfile(folder, [fName fExt]);
    if exist(DATA_FILE, 'file'),
        copyfile(DATA_FILE, dataFileCopy);
        copyfile(evFile, evFileCopy);
    else
        urlwrite([DATA_URL fName fExt], dataFileCopy);
        urlwrite([DATA_URL fName '.events.csv'], evFileCopy);
    end
    
    myImporter = poly5(...
        'FileName',     catfile(folder, 'myfile'), ...
        'Temporary',    false);
    stat = set_warning_status(WARN_IDS, 'off');
    import(myImporter, dataFileCopy);
    set_warning_status(WARN_IDS, stat);
    
    psetExt = pset.globals.get.DataFileExt;
    newFile = catfile(folder, ['myfile' psetExt]);
    ok(exist(newFile, 'file') > 0, name);
    
catch ME
    
    set_warning_status(WARN_IDS, 'on');
    ok(ME, name);
    MEh = [MEh ME];
    
end


%% Cleanup
try
    
    name = 'cleanup';
    clear data;
    rmdir(session.instance.Folder, 's');
    session.clear_subsession();
    ok(true, name);
    
catch ME
    ok(ME, name);
end

%% Testing summary
status = finalize();