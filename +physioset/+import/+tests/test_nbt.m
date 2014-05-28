function [status, MEh] = test_nbt()
% TEST_NBT - Test importer for NeuroBiomarkers Toolbox .mat files
%
% See also: physioset.import.nbt

import mperl.file.spec.*;
import test.simple.*;
import pset.session;
import safefid.safefid;
import datahash.DataHash;
import misc.rmdir;
import misc.set_warning_status;

% The sample data file to be used for testing
DATA_FILE = 'NBT.S0021.090205.EOR1';
DATA_URL = 'http://kasku.org/data/meegpipe/';
WARN_IDS = { 'sensors:InvalidLabel', 'sensors:MissingPhysDim' };

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
    physioset.import.nbt;
    ok(true, name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% import sample data
try
    
    name = 'import sample data file';
    
    if ~exist([DATA_FILE '.mat'], 'file'),
        urlwrite([DATA_URL DATA_FILE '.mat'], [DATA_FILE '.mat']);
        urlwrite([DATA_URL DATA_FILE '_info.mat'], [DATA_FILE '_info.mat']);
    end   
    stat = set_warning_status(WARN_IDS, 'off');
    data = import(physioset.import.nbt, [DATA_FILE '.mat']);
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
    if ~exist(DATA_FILE_2, 'file'),
        urlwrite([DATA_URL fName fExt], DATA_FILE_2);
        urlwrite([DATA_URL fName '.events.csv'], evFile);
    end
    files = somsds.link2files({DATA_FILE_2, evFile}, folder);
    stat = set_warning_status(WARN_IDS, 'off');
    data = import(poly5, files{1});
    set_warning_status(WARN_IDS, stat);
    
    ok(all(size(data) == [37 1743921]) & numel(get_event(data)) == 0, name);
    
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
    if ~exist(DATA_FILE, 'file'),
        urlwrite([DATA_URL fName fExt], DATA_FILE);
        urlwrite([DATA_URL fName '.events.csv'], evFile);
    end
    files = somsds.link2files({DATA_FILE, evFile}, folder);
    myImporter = poly5(...
        'FileName',     catfile(folder, 'myfile'), ...
        'Temporary',    false);
    stat = set_warning_status(WARN_IDS, 'off');
    import(myImporter, files{1});
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