function [status, MEh] = test_eog()
% test_eog - EOG removal

import mperl.file.spec.*;
import meegpipe.node.*;
import test.simple.*;
import pset.session;
import safefid.safefid;
import datahash.DataHash;
import misc.rmdir;
import oge.has_oge;
import spt.bss.jade;

MEh     = [];

initialize(3);

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

%% topo_ratio criterion
try
    
    name = 'topo_ratio criterion';
    [data, S, sensIdx] = sample_data;
    
    othersIdx = sort(setdiff(1:size(data,1), sensIdx));
    
    sensLabels = labels(subset(sensors(data), sensIdx));
    othersLabels = labels(subset(sensors(data), othersIdx));
    myCrit = spt.criterion.topo_ratio.new(...
        'SensorsNumLeft',   sensLabels, ...
        'SensorsDen',       othersLabels, ...
        'Max', @(r) median(r) + 2*mad(r));
    
    snrOrig = signal_to_noise(data, S);
    myNode = bss_regr.eog('Criterion', myCrit, 'Var', 100, ...
        'GenerateReport', false);
    
    run(myNode, data);
    snrNew = signal_to_noise(data, S);
    
    ok(snrNew > snrOrig, name);
   
catch ME
 
    ok(ME, name);
    status = finalize();
    return;
    
end


%% Cleanup
try
    
    name = 'cleanup';
    clear data dataCopy;
    rmdir(session.instance.Folder, 's');
    session.clear_subsession();
    ok(true, name);
    
catch ME
    ok(ME, name);
end

%% Testing summary
status = finalize();

end


function [data, S, sensIdx] = sample_data()

sens = sensors.eeg.from_template('egi256');

sens = subset(sens, 1:10);

S = rand(8, 10000);
S = S - repmat(mean(S,2), 1, size(S,2));

t = 0:size(S,2)-1;
N = 0.5*[cos(2*pi*(1/500)*t).*sin(2*pi*(1/1000)*t); cos(2*pi*(1/750)*t)];
N = N - repmat(mean(N,2), 1, size(N,2));

% Sensors where the EOG artifact will be greatest
tmp = randperm(10);
sensIdx = sort(tmp(1:2));

% Mixing matrix
A = rand(10);

% Ensure that the projection of the EOG sources is maximal to the EOG sens
A(sensIdx,1:size(N,1)) = ...
    max(abs(A(:)))*(5+randi(10, numel(sensIdx), size(N,1)));

A = misc.unit_norm(A);
A(:,1:2) = 5*A(:,1:2);

data = A*[N;S];

data = import(physioset.import.matrix('Sensors', sens), data);

S = A(:,size(N,1)+1:end)*S;


end


function snr = signal_to_noise(X, S)

snr = 0;
for i = 1:size(X,1)
    snr = snr + var(S(i,:))/var(X(i,:)-S(i,:));
end
snr = 10*log10(snr/size(X,1));

end