function [status, MEh] = complex_pipelines()
% TEST_COMPLEX_PIPELINES - Tests some more complex pipelines

import mperl.file.spec.*;
import meegpipe.node.*;
import test.simple.*;
import pset.session;
import safefid.safefid;
import datahash.DataHash;
import misc.rmdir;
import oge.has_oge;
import misc.get_username;
import misc.get_hostname;


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

%% copy+eog+chan_interp
try
    data = get_real_data;
    
    set_bad_channel(data, [10 18 21 192]);
    set_bad_sample(data, randi(size(data,2), 1, 1125));
    data = subset(data, 1:192);
    
    save(data);
    dataFile = get_hdrfile(data);
    myPipe = pipeline.new('NodeList', {...
        physioset_import.new('Importer', physioset.import.physioset), ...
        copy.new, ...
        bss.eog, ...
        chan_interp.new ...
        }, ...
        'Save', true, 'GenerateReport', true, 'Name', 'sample');
    
    run(myPipe, dataFile);

    ok(true, name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end


%% copy+resample+filter+reref+bad_channels+bad_epochs
try
    
    name = 'process sample data';
    
    centralchannels= pset.selector.sensor_idx(sort([257, 81, 132, 186,9,45, 8, 198, 185, 144, 131, 90, 80, 53, 44, 17]));
    badChanDataSel = not(centralchannels);
    
    badChanCrit1 = bad_channels.criterion.var.new(...
        'Min', @(chanVar) prctile(chanVar, 1), ...
        'Max', @(chanVar) prctile(chanVar, 95), ...
        'MaxCard',  @(dim)ceil(0.2*dim), ...
        'NN',  20 ... % Number of nearest neighbors
        );
    badChanCrit2 = bad_channels.criterion.xcorr.new(...
    'MinCard',  0,  ...
    'MaxCard',  @(dim)ceil(0.05*dim), ...
    'Min',      @(corrVals) prctile(corrVals,5) ...
    );
    
    fh = @(sampl, idx, data) physioset.event.event(sampl, ...
        'Type', '_DummyEpochOnset', 'Duration', 2*data.SamplingRate);
    
    myEvGen = physioset.event.periodic_generator(...
        'Period',   2, ... % in seconds
        'Template', fh  ...
        );
    
    badEpochsCrit = bad_epochs.criterion.stat.new(...
        'ChannelStat', @(epochdata) max(abs(epochdata)), ...
        'EpochStat', @(chanstat) prctile(chanstat,95), ...
        'Min', @(epochStatVal) median(epochStatVal)-3*iqr(epochStatVal), ...
        'Max', @(epochStatVal) median(epochStatVal)+2*iqr(epochStatVal) ...
        );
    
    myEvSel = physioset.event.class_selector('Type', '_DummyEpochOnset');
    
    badEpochsNode  = bad_epochs.new(...
        'Criterion',        badEpochsCrit, ...
        'EventSelector',    myEvSel);
    myPipe = pipeline.new(...
        bad_channels.new('Criterion', badChanCrit1, 'DataSelector', badChanDataSel), ...
        bad_channels.new('Criterion', badChanCrit2, 'DataSelector', badChanDataSel), ...
        ev_gen.new('EventGenerator', myEvGen), ...
        badEpochsNode, ...
        tfilter.new('Filter', @(sr) filter.bpfilt('fp', [0.25 40]/(sr/2))), ...
        copy.new, ...
        physioset_import.new('Importer', physioset.import.physioset), ...
        resample.new('OutputRate', 125), ...
        'Save', true, 'GenerateReport', true);
    
    if ~strcmp(get_hostname, 'somerenserver'),
        myImporter = physioset.import.matrix(...
            'Sensors', sensors.eeg.from_template('egi256'));
        myData = import(myImporter, rand(257, 10000));
        save(myData);   
        myData = get_hdrfile(myData);
    else
        myData = 'ssmd_0104_eeg_rs-ec_ssmd-rs.pseth';
    end
   
    run(myPipe, myData);
    
    ok(true, name);
    
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


function data = get_real_data()

if exist('20131121T171325_647f7.pseth', 'file') > 0,
    data = pset.load('20131121T171325_647f7.pseth');
else
    % Try downloading the file
    url = 'http://kasku.org/data/meegpipe/20131121T171325_647f7.zip';
    unzipDir = catdir(session.instance.Folder, '20131121T171325_647f7');
    unzip(url, unzipDir);
    fileName = catfile(unzipDir, '20131121T171325_647f7.pseth');
    data = pset.load(fileName);
end
data = copy(data);

end