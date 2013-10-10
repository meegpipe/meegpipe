function generate_rank_report(rep, critObj, rankIdx, nbSel)

import meegpipe.node.globals;
import misc.unique_filename;
import mperl.file.spec.catfile;
import plot2svg.plot2svg;
import report.object.object;
import inkscape.svg2png;

verbose      = goo.globals.get.Verbose;
verboseLabel = goo.globals.get.VerboseLabel;

% Deactivate verbose mode for any function call
goo.globals.set('Verbose', false);

if verbose
    fprintf( [verboseLabel, 'Generating components'' rank report...']);
end

gallery = clone(globals.get.Gallery);

visible = globals.get.VisibleFigures;

if visible,
    visibleStr = 'on';
else
    visibleStr = 'off';
end

figure('Visible', visibleStr);

plot(rankIdx, 'k', 'LineWidth', 1.5*globals.get.LineWidth);
hold on;

% Plot a line marking the boundary between selected/unselected components
grid on;
yLim = get(gca, 'YLim');
axis([0.75 numel(rankIdx)+0.25 yLim(1) yLim(2)]);
if nbSel > 0,
    plot(nbSel, rankIdx(nbSel), 'ro', 'MarkerFaceColor', 'Red');
    line([nbSel nbSel], [yLim(1) yLim(2)], 'LineStyle', '-', 'Color', 'Red');
end

xlabel('SPC index');
ylabel('Normalized rank value');

% Print to .svg and .png format
rootPath = get_rootpath(rep);
fileName = catfile(rootPath, 'rank-report.svg');
fileName = unique_filename(fileName);

caption = sprintf(['Sorted rank value for each spatial component.' ...
    ' The red line marks the boundary between selected and unselected' ...
    ' components ']);

evalc('plot2svg(fileName, gcf);');
svg2png(fileName);

close;

gallery = add_figure(gallery, fileName, caption);

%% Print the report
print_title(rep, 'SPC selection criterion', get_level(rep) + 1);

% Information about the criterion
objReport = object(critObj, 'Title', ['Criterion ' get_name(critObj)]);
childof(objReport, rep);
generate(objReport); 
fprintf(rep, 'Components selected with criterion ');
print_link2report(rep, objReport, get_name(critObj));

fprintf(rep, gallery);

if verbose, fprintf('[done]\n\n'); end

% Return to original verbose mode
goo.globals.set('Verbose', verbose);

end