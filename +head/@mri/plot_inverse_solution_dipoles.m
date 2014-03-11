function h = plot_inverse_solution_dipoles(obj, varargin)
% PLOT_INVERSE_SOLUTION_DIPOLES
% Plots the strength of the inverse solution at each source voxel
%
% plot_inverse_solution_dipoles(obj)
%
% plot_inverse_solution_dipoles(obj, 'key', value, ...)
%
%
% where
%
% OBJ is a head.mri object
%
%
% Common key/value pairs:
%
% 'Time'        : A scalar that specifies the time instant that should be
%                 considered. Use time=1 if the scalp potentials do not
%                 have any temporal variation. Default: 1
%
% 'Momemtum'    : A scalar that modifies the length of the plotted dipole
%                 momemtums. If not provided, the momemtums will not be
%                 plotted
%
% 'SizeData'    : A scalar that modifies the size of the voxel markers. Use
%                 higher values to linearly increase the size of each
%                 marker.
%
% 'Exp'         : A scalar that specifies the exponent that should be
%                 applied to the source activation in order to determine
%                 marker size. Use higher values to highlight stronger
%                 source activations. Default: 2
%
%
% Less common key/value pairs:
%
% 'surface'     : A boolean determining whether the brain surface should be
%                 plotted. Default: true
%
% 'linwidth'    : A scalar that modifies the thickness of the dipole
%                 momemtum lines. Default: 2
%
%
% See also: head.mri

% Description: Plot inverse solution strength
% Documentation: class_head_mri.txt


import misc.process_varargin;

keySet = {'momemtum', 'surface', 'linewidth','sizedata','time','exp'};
momemtum = false;
surface = true;
sizedata=100;
exp=2;
time=[];

eval(process_varargin(keySet, varargin));

h = []; %#ok<NASGU>
% Plot the brain surface
if surface,
    h = plot(obj, 'surface', 'InnerSkull', 'sensors', false);
    set(h(1), 'facealpha', 0.02);
    set(h(1), 'edgealpha', 0.03);
end


thisSource = obj.InverseSolution;
points = obj.SourceSpace.pnt(thisSource.pnt,:);

thisH = scatter3(points(:,1), points(:,2), points(:,3), 'filled');
if ~isempty(time),
    act = abs(thisSource.strength.*thisSource.activation(:,time)).^exp;
    act = act./max(abs(act));
    act(act<eps) = 0.000001*max(abs(act));
    set(thisH, 'SizeData', sizedata*abs(act));   
else
    set(thisH, 'SizeData', sizedata);
end
set(thisH, 'CData', [0 0 0]);
h = [h thisH]; %#ok<*AGROW>


sourceIdx = [];
for i = 1:obj.NbSources,
    if strcmpi(obj.Source(i).name,'noise'), continue; end
    sourceIdx = [sourceIdx i];
end
if ~isempty(sourceIdx)
    hold on;
    thisH = plot_source_dipoles(obj, sourceIdx, 'sizedata', sizedata, ...
        'time', time, 'exp', exp, 'momemtum', momemtum, 'inversesolution',true);
    set(thisH(2), 'MarkerFaceColor', 'none');
    set(thisH(2), 'MarkerEdgeColor', 'flat');
    set(thisH(2), 'LineWidth',2);
    h = [h thisH];
end


end