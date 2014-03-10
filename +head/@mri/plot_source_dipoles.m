function h = plot_source_dipoles(obj, index, varargin)
% PLOT_SOURCE_DIPOLES
% Plot source dipoles
%
% plot_source_dipoles(obj, index)
%
% plot_source_dipoles(obj, index, 'key', value, ...)
%
%
% where
%
% OBJ is a head.mri object
%
% INDEX is a set of source indices or a cell array with source names
%
%
% Accepted (optional) key/value pairs:
%
% momentum  : if not zero, the momentum of each dipole will also be plotted.
%             Defaults to 1. Use higher values to display longer arrows for
%             each dipole
%
% 
% See also: head.mri

import misc.process_varargin;

COLORS = {[0 1 0], [1 0 0], [0 0 1], [0.7 0.5 0.1], [0.1 0.5 0.3]};

if isempty(obj.Source) || isempty(index),
    return;
end

keySet = {'momentum', 'surface', 'linewidth','sizedata','time', 'exp', 'color'};
momentum = false;
surface = true;
linewidth=2;
sizedata=70;
time=[];
exp=1.5;
color =[];

eval(process_varargin(keySet, varargin));

if ~isempty(time),
    sizedata = sizedata/4;
end

if ischar(index) || iscell(index),
    index = source_index(obj, index);
end

if numel(momentum)==1 && numel(index)>1,
    momentum = repmat(momentum, numel(index),1);
end
h = [];
% Plot the brain surface
if surface,
    h = plot(obj, 'surface', 'InnerSkull', 'sensors', false);
    set(h(1), 'facealpha', 0.02);
    set(h(1), 'edgealpha', 0.03);
end

for i = 1:numel(index)
   thisSource = obj.Source(index(i));    
   points = obj.SourceSpace.pnt(thisSource.pnt,:);
   
   if isempty(color),
       if i > numel(COLORS),
           thisColor = rand(1,3);
       else
           thisColor = COLORS{i};
       end
   else
       thisColor = color(min(size(color,1), i),:);
   end

   thisH = scatter3(points(:,1), points(:,2), points(:,3), 'filled');
   if ~isempty(time),
       set(thisH, 'SizeData', sizedata*abs(thisSource.strength.*thisSource.activation(:,time)).^exp);
   else
       set(thisH, 'SizeData', sizedata);
   end
   set(thisH, 'CData', thisColor);
   h = [h thisH]; %#ok<*AGROW>
   if momentum(i)
       hold on;
       m = obj.Source(index(i)).momentum*momentum(i);
      
       if ~isempty(time), 
          m = m.*abs(repmat((thisSource.strength.*thisSource.activation(:,time)),1,3));
       end
       thisH = quiver3(points(:,1), points(:,2), points(:,3), m(:,1), m(:,2), m(:,3),0);
       set(thisH, 'color', thisColor);
       set(thisH, 'linewidth', linewidth);
       set(thisH, 'autoscale', 'off');
       set(thisH, 'autoscalefactor', 1);
       h = [h thisH];
   end
end


end