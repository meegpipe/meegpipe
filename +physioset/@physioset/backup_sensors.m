function obj = backup_sensors(obj, proj)

import datahash.DataHash;

if nargin < 2 || isempty(proj),
    proj = rand;
end

obj.ProjectionHistory = [obj.ProjectionHistory;{DataHash(proj)}];
obj.SensorsHistory    = [obj.SensorsHistory;{obj.Sensors}];

end