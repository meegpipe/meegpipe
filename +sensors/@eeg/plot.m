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

cartesian = obj.Cartesian(~any(isnan(obj.Cartesian')), :);
if isempty(cartesian),
    h = [];
    % Nothing to plot
    return;
end

[args1, varargin] = ...
    split_arguments({'Labels', 'Project2D', 'Visible'}, varargin);

opt.Labels    = false;
opt.Project2D = false;
opt.Visible   = true;
[~, opt] = process_arguments(opt, args1);

if numel(varargin) < 2,
    varargin = {'r', 'filled'};
end

if opt.Visible,
    visible = 'on';
else
    visible = 'off';
end

h = figure('Visible', visible);
if opt.Project2D,
    if opt.Labels,
        electrodes = 'labels';
    else
        electrodes = 'on';
    end    
    topoplot([], eeglab(obj), 'whitebk', 'on', ...
        'electrodes', electrodes);
    
    % Make the labels smaller
    if opt.Labels && obj.NbSensors > 64,
        hT = findobj(h, 'type', 'text');
        baseFontSize = get(hT(1), 'FontSize');
        for i = 1:numel(hT)
            set(hT, 'FontSize', floor(baseFontSize*0.7));
        end
    end     
else
    scatter3(obj.Cartesian(:,1), cartesian(:,2), cartesian(:,3), varargin{:});
    
    axis equal;
    set(gca, 'visible', 'off');
    set(gcf, 'color', 'white');
    
    if opt.Labels,
        text(cartesian(:,1), cartesian(:,2), cartesian(:,3), labels(obj));
    end
end

end