function myNode = sparse_sensor_noise(varargin)
% SPARSE_SENSOR_NOISE - Correct noise generated at a single sensor

warning('node:bss:deprecated', ...
    ['This function has been deprecated. ' ...
    'Use aar.sensor_noise.sparse_sensor_noise instead']);

myNode = aar.sensor_noise.sparse_sensor_noise(varargin{:});

end