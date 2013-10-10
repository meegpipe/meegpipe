function obj = eog_egi256_hcgsn1(varargin)
% eog_egi256_hcgsn1 - Rejects EOG components using topography
%
% This node pre-configuration should be used only in combination with an
% EGI 256 sensor net HCGSN v1.0.
%
% See also: bss_regr.eog

import misc.process_arguments;
import meegpipe.node.*;
import misc.split_arguments;

opt.MinCard = 2;
opt.MaxCard = 5;
opt.Max     = 15;

[thisArgs, varargin] = split_arguments(fieldnames(opt), varargin);

[~, opt] = process_arguments(opt, thisArgs);

sensorsNumLeft = [...
    241 244 248 252 253 67 61 54 46 37 32, ...
    47 38 33];

sensorsNumRight = [...
    238 234 230 226 225 219 220 1 10 18 25, ...
    2 11 19];

sensorsNumMid = {'EEG 31', 'EEG 26'}; 

sensorsNumLeft = arrayfun(@(x) ['EEG ' num2str(x)], sensorsNumLeft, ...
    'UniformOutput', false);
    
sensorsNumRight = arrayfun(@(x) ['EEG ' num2str(x)], sensorsNumRight, ...
    'UniformOutput', false);
    


allSensors = sensors.eeg.from_template('egi256');

isNumL = match_label_regex(allSensors, sensorsNumLeft);
isNumR = match_label_regex(allSensors, sensorsNumRight);
isNum = isNumL | isNumR;

% Approximate distance between sensors
dist = euclidean_dist(allSensors);

% Rank all sensors based on their distance to the numerator sensors
rank = min(dist(isNum, ~isNum));
denIdx = find(~isNum);
[~, order] = sort(rank, 'descend');

% Pick the farthest sensors
sensorsNumLabels = [sensorsNumLeft(:);sensorsNumRight(:);sensorsNumMid(:)];
maxSensors = allSensors.NbSensors - max(2*numel(sensorsNumLabels), 70);
maxSensors = max(10, maxSensors);
denIdx = denIdx(order(1:maxSensors));

sensorsDen = subset(allSensors, sort(denIdx));

myCrit = spt.criterion.topo_ratio.new(...
    'SensorsDen',       labels(sensorsDen), ...
    'SensorsNumLeft',   sensorsNumLeft, ...
    'SensorsNumRight',  sensorsNumRight, ...
    'SensorsNumMid',    sensorsNumMid, ...
    'MaxCard',          opt.MaxCard, ...
    'MinCard',          opt.MinCard, ...
    'Max',              opt.Max, ...
    'FunctionDen',      @(x) prctile(x.^2, 75), ...
    'FunctionNum',      @(x) prctile(x.^2, 75), ...
    'Symmetrical',      true);

obj = bss_regr.eog('Criterion', myCrit, 'Name', 'eog-topo', ...
    varargin{:});


end