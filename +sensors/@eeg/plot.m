function h = plot(obj, varargin)
% PLOT - Scatter plot of sensor locations
%
% plot(obj)
% plot(obj, 'Labels', true);
%
% Where
%
% OBJ is a sensors.eeg object
% 
%
% See also: sensors.eeg

import misc.split_arguments;
import misc.process_arguments;


[args1, varargin] = split_arguments({'Labels'}, varargin);

opt.Labels = false;
[~, opt] = process_arguments(opt, args1);

if numel(varargin) < 2,
    varargin = {'r', 'filled'};
end


h = scatter3(obj.Cartesian(:,1), obj.Cartesian(:,2), obj.Cartesian(:,3), varargin{:});

axis equal;
set(gca, 'visible', 'off');
set(gcf, 'color', 'white');

if opt.Labels,
    text(obj.Cartesian(:,1), obj.Cartesian(:,2), obj.Cartesian(:,3), labels(obj));
end

end