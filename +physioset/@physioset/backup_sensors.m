function obj = backup_sensors(obj)


obj.SensorsHistory = [obj.SensorsHistory;{obj.Sensors}];

end