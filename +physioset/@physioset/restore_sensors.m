function obj = restore_sensors(obj, proj)

import datahash.DataHash;

if isempty(obj.SensorsHistory),
    warning('physioset:NoSensorHistory', ...
        'There are not previous sensors to be restored');
    return;
end

if nargin < 2 || isempty(proj),
    proj = rand;
end

projIdx = find(ismember(obj.ProjectionHistory, DataHash(proj)));

if numel(projIdx) > 1,
    warning('physioset:MultipleIdenticalProjections', ...
        ['Multiple identical projections found in ProjectionHistory: ' ...
        'using last one']);
    projIdx = projIdx(end);
end

if isempty(projIdx) && numel(obj.SensorsHistory) == 1,
    projIdx = 1;
end

if isempty(projIdx),
   % Better just to do nothing since not recovering the sensors is probably
   % acceptable in most cases and preferable to throwing an error
   return;   
end

obj.Sensors = obj.SensorsHistory{projIdx};

obj.SensorsHistory{projIdx} = [];
obj.ProjectionHistory{projIdx} = [];


end