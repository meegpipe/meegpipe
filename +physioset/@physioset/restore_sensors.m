function obj = restore_sensors(obj)

if isempty(obj.SensorsHistory),
    warning('physioset:NoSensorHistory', ...
        'There are not previous sensors to be restored');
    return;
end

obj.Sensors = obj.SensorsHistory{end};

obj.SensorsHistory{end} = [];


end