function count = fprintf(fid, obj, gallery)
% FPRINTF - Print remark report
%
% count = fprintf(fid, obj)
%
% Where
%
% FID is an open file handle or a io.safefid object.
%
% OBJ is an already trained spt.pca.pca object.
%
% GALLERY is a gallery object, that especifies the formatting of the
% generated Remark gallery
%
% See also: learn, pca, report.report, io.safefid


import meegpipe.node.globals;
import misc.unique_filename;
import misc.fid2fname;
import mperl.file.spec.catfile;
import plot2svg.plot2svg;
import report.object.object;
import inkscape.svg2png;

if nargin < 3 || isempty(gallery),
    gallery = report.gallery.gallery;
end


% Information about the pca parameters
targetFileName = fid2fname(fid);

% IMPORTANT: The line below is necessary to prevent an infinite recursion.
% Generating a report on a pca object calls fprintf on the same object.
% This solution is ugly but will do for now
%str = struct(obj);
objectReport = object(obj, 'Title', 'Principal Components Analysis');
objectReport = childof(objectReport, targetFileName);
initialize(objectReport);
generate(objectReport);
pcaClass = class(obj);
[~, repName] = fileparts(get_filename(objectReport));
fprintf(fid, 'PCA performed using [%s][%s]\n', pcaClass, repName);
fprintf(fid, '[%s]: [[Ref: %s]]\n\n', repName, [repName '.txt']);

visible = globals.get.VisibleFigures;

if visible,
    visibleStr = 'on';
else
    visibleStr = 'off';
end

figure('Visible', visibleStr);

% We plot only the relevant eigenvalues and a bit more
eigenValues = flipud(obj.Eigenvalues(:));
eigenValues(obj.NbComp+2:end) = [];
critVals = obj.CriterionValues;
critVals(obj.NbComp+2:end) = [];

eigenValues = eigenValues-min(eigenValues);
eigenValues = eigenValues/max(eigenValues);

plot(eigenValues, 'k', 'LineWidth', 1.5*globals.get.LineWidth);
hold on;
xlabel('Principal component index');
if ~isempty(critVals)
    critVals = critVals - min(critVals);
    critVals = critVals/max(critVals);
    critVals = flipud(critVals(:));
    critVals(obj.NbComp + 2:end) = [];
    plot(critVals, 'g', 'LineWidth', 1.5*globals.get.LineWidth);
    ylabel('Normalized value');
    critName = get_config(obj, 'Criterion');
    legend('Eigenvalues', [upper(critName) ' criterion']);
else
    ylabel('Normalized eigenvalue');
end

% Instead we avoid transparent elements and just plot a line
grid on;
yLim = get(gca, 'YLim');
axis([1 numel(eigenValues)+0.25 yLim(1) yLim(2)]);
plot(obj.NbComp, eigenValues(obj.NbComp), 'ro', 'MarkerFaceColor', 'Red');
plot(obj.DimOut, eigenValues(obj.DimOut), 'bo', 'MarkerFaceColor', 'Blue');
line([obj.NbComp obj.NbComp], [yLim(1) yLim(2)], ...
    'LineStyle', ':', 'Color', 'Red');
line([obj.DimOut obj.DimOut], [yLim(1) yLim(2)], ...
    'LineStyle', '-', 'Color', 'Blue');


str = sprintf('rank = %d', obj.NbComp);
hT = text(obj.NbComp-1, yLim(1)+0.1*diff(yLim), str);
set(hT, ...
    'FontWeight',   'bold',  ...
    'Rotation',     90 ...
    );

str = sprintf('#comp = %d ', obj.DimOut);
hT = text(obj.DimOut-1, yLim(1)+0.1*diff(yLim), str);
set(hT, ...
    'FontWeight',   'bold',  ...
    'Rotation',     90 ...
    );


% Print to .svg and .png format
rootPath = fileparts(targetFileName);

fileName = catfile(rootPath, [repName '.svg']);

caption = sprintf(['Eigenvalues of the PCA decomposition. The red line' ...
    ' marks the boundary between selected and unselected principal ' ...
    'components ']);

evalc('plot2svg(fileName, gcf);');

svg2png(fileName);

close;

gallery = add_figure(gallery, fileName, caption);

%% Print a gallery
count = fprintf(fid, gallery);



end