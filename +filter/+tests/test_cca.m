function [status, MEh] = test_cca()
% TEST_CCA - Tests filter cca

import mperl.file.spec.*;
import test.simple.*;
import pset.session;
import safefid.safefid;
import datahash.DataHash;
import misc.rmdir;

MEh     = [];

initialize(8);

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

%% constructor
try
    
    name = 'constructor';
    
    myFilt = filter.cca;
    
    cond = isa(myFilt, 'filter.cca') & isa(myFilt, 'filter.dfilt');
    
    myFilt = filter.cca(...
        'MaxCorr',  0.8, ...
        'MinCorr',  0.2, ...
        'MaxCard',  5, ...
        'MinCard',  2, ...
        'CCA',      spt.bss.cca, ...
        'Name',     'myCCA');
    
    cond = cond & ...
        isa(myFilt.CCA, 'spt.bss.cca') & ...
        myFilt.MaxCorr == 0.8 & ...
        myFilt.MinCorr == 0.2 & ...
        myFilt.MaxCard == 5 & ...
        myFilt.MinCard == 2 & ...
        strcmp(get_name(myFilt), 'myCCA');
    
    ok(cond, name);
    
catch ME
    
    ok(ME, name);
    status = finalize();
    return;
    
end

%% Sample filtering
try
    
    name = 'sample filtering';
    
    [data, ~, S, ~, snr] = sample_data();
    myFilter = filter.cca('MinCard', 2, 'MaxCard', 2);    
    
    filter(myFilter, data);
    
    snrAfter = 0;
    for i = 1:size(data,1)
        snrAfter = snrAfter + var(S(i,:))/var(data(i,:)-S(i,:));
    end
    snrAfter = snrAfter/size(data,1);
    ok(snrAfter > 20*snr, name);
    
catch ME
    
    ok(ME, name);
    status = finalize();
    return;
    
end

%% Sample filtering with component filter
try
    
    name = 'sample filtering with component filter';
    
    [data, ~, S, ~, snr] = sample_data();
    myFilter = filter.cca('MinCard', 2, 'MaxCard', 2, ...
        'ComponentFilter', filter.lpfilt('fc', 0.1));    
    
    filter(myFilter, data);
    
    snrAfter = 0;
    for i = 1:size(data,1)
        snrAfter = snrAfter + var(S(i,:))/var(data(i,:)-S(i,:));
    end
    snrAfter = snrAfter/size(data,1);
    ok(snrAfter > 50*snr, name);
    
catch ME
    
    ok(ME, name);
    status = finalize();
    return;
    
end

%% sliding_window
try
    
    name = 'sliding_window';
    
    [data, ~, S, ~, snr] = sample_data();
    myFilter = filter.cca('MinCard', 2, 'MaxCard', 2);  
    myFilter = filter.sliding_window(myFilter, ...
        'WindowLength', 1000);
    
    filter(myFilter, data);
    
    snrAfter = 0;
    for i = 1:size(data,1)
        snrAfter = snrAfter + var(S(i,:))/var(data(i,:)-S(i,:));
    end
    snrAfter = snrAfter/size(data,1);
    ok(snrAfter > 20*snr, name);
    
catch ME
    
    ok(ME, name);
    status = finalize();
    return;
    
end

%% real data
try
    
    name = 'real data';
    
    data = real_data;
    myFilter = filter.cca('MinCard', 2, 'MaxCard', 2);  
    myFilter = filter.sliding_window(myFilter, ...
        'WindowLength', 1000);
    myFilter = filter.pca('PCFilter', myFilter, ...
        'PCA', spt.pca('MaxCard', 15));
    
    filter(myFilter, data);

    ok(true, name);
    
catch ME
    
    ok(ME, name);
    status = finalize();
    return;
    
end

%% pipeline + real data
try
    
    name = 'pipeline + real data';
    
    data = kul_data;
    myFilter = filter.cca('MinCard', 2, 'MaxCard', 2);  
    myFilter = filter.sliding_window(myFilter, ...
        'WindowLength', 1000);
    myFilter = filter.pca('PCFilter', myFilter, ...
        'PCA', spt.pca('MaxCard', 15));
    
    filter(myFilter, data);

    ok(true, name);
    
catch ME
    
    ok(ME, name);
    status = finalize();
    return;
    
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



function [data, S, N, R, snr] = sample_data()

f = 1/100;
snr = 0.25;

S = randn(10, 50000);
N = zeros(size(S));

t = 0:size(S,2)-1;
for i = 1:size(S,1)
    N(i,:) = sqrt(2)*sin(2*pi*f*t+randi(100));        
end

N = (1/sqrt(snr))*N;
X = S + N;

R = zeros(2, size(S,2));
R(1,:) = sin(2*pi*f*t);
R(2,:) = cos(2*pi*f*t);

data = import(physioset.import.matrix, X);



end


function dataCopy = real_data()

import pset.session;
import mperl.file.spec.catfile;
import mperl.file.spec.catdir;

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
dataCopy = copy(data);

end


function fileName = kul_data()

import pset.session;
import mperl.file.spec.catfile;
import mperl.file.spec.catdir;

fileName = catfile(session.instance.Folder, 'f1_750to810.set');

if exist('f1_750to810.set', 'file') > 0,
    copyfile('f1_750to810.set', fileName);
else
    % Try downloading the file
    url = 'http://kasku.org/projects/eeg/data/kul/f1_750to810.set';
    urlwrite(url, fileName);  
end

end