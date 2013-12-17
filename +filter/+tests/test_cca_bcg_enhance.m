function [status, MEh] = test_cca_bcg_enhance()
% TEST_CCA_BCG_ENHANCE - Tests filter cca.bcg_enhance

import mperl.file.spec.*;
import test.simple.*;
import pset.session;
import safefid.safefid;
import datahash.DataHash;
import misc.rmdir;

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

%% constructor
try
    
    name = 'constructor';
    
    myFilt = filter.cca.bcg_enhance;
    
    cond = isa(myFilt, 'filter.cca') & isa(myFilt, 'filter.dfilt');
    
    myFilt = filter.cca.bcg_enhance(...
        'MaxCorr',  0.8, ...
        'MinCorr',  0.2, ...
        'MaxCard',  5, ...
        'MinCard',  2, ...
        'Name',     'myCCA');
    
    cond = cond & ...
        isa(myFilt.CCA, 'spt.bss.cca') & ...
        isa(myFilt.CCA.Delay, 'function_handle') & ...
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
    
    myCCFilter = filter.tpca('Order', 50, 'PCA', spt.pca('RetainedVar', 95));
    
    myFilter = filter.cca.bcg_enhance(...
        'MinCard', 2, ...
        'MaxCard', 2, ...
        'CCFilter', myCCFilter);    
    
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
    
    myCCFilter = filter.tpca(...
        'Order',    50, ...
        'PCA',      spt.pca('RetainedVar', 95));
    
    myFilter = filter.cca.bcg_enhance(...
        'MinCard',      2, ...
        'MaxCard',      2, ...
        'SamplingRate', 150, ...
        'CCFilter',     myCCFilter);    
    
    myFilter = filter.sliding_window(myFilter, ...
        'WindowLength', 1000);
    
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

%% real data
try
    
    name = 'real data';
    
    data = real_data;
    
    myFilter = filter.cca.bcg_enhance(...
        'MinCorr',      @(x) median(x), ...
        'SamplingRate', data.SamplingRate ...
        );
    
    myFilter = filter.sliding_window(myFilter, ...
        'WindowLength', 5000);
    
    myFilter = filter.pca(...
        'PCA', spt.pca('RetainedVar', 99.99), ...
        'PCFilter', myFilter);
    
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

% We use a sampling rate of 150 so that the 100 sample period looks like
% the typical cardiac cycle period (about 90 bpm). 
myImporter = physioset.import.matrix('SamplingRate', 150);
data = import(myImporter, X);



end


function dataCopy = real_data()

import pset.session;
import mperl.file.spec.catfile;
import mperl.file.spec.catdir;

if exist('bcg_sample.pseth', 'file') > 0,
    data = pset.load('bcg_sample.pseth');
else
    % Try downloading the file
    url = 'http://kasku.org/data/meegpipe/bcg_sample.zip';
    unzipDir = catdir(session.instance.Folder, 'bcg_sample');
    unzip(url, unzipDir);
    fileName = catfile(unzipDir, 'bcg_sample.pseth');
    data = pset.load(fileName);
end
dataCopy = copy(data);

end

