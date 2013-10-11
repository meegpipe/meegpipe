function h = plot_mesh(vert, tri, varargin)

import misc.process_arguments;

opt.facecolor = [0.3 0.3 0.3];
opt.facealpha = 0.5;
opt.edgecolor = [0 0 0];
opt.edgealpha = 0.1;
if nargin < 2
    opt.plotvertices = true;
else
    opt.plotvertices = false;
end

[~, opt] = process_arguments(opt, varargin);

if nargin < 2,
    tri = [];
end

if isempty(tri),
    dt = DelaunayTri(vert);
    h = tetramesh(dt);
    hold on;
    scatter3(vert(:,1), vert(:,2), vert(:,3), 'r', '.');
else
    tr = TriRep(tri, vert(:,1), vert(:,2), vert(:,3));
    h=trimesh(tr);    
end
set(h, ...
    'FaceColor', opt.facecolor, ...
    'FaceAlpha', opt.facealpha, ...
    'EdgeColor', opt.edgecolor, ...
    'EdgeAlpha', opt.edgealpha);
axis equal;
set(gca, 'visible', 'off');
set(gcf, 'color', 'white');

end