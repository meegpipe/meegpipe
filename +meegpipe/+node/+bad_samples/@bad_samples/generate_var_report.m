function generate_var_report(rep, isRej, lowVar, topVar, ...
    minValLow, maxValLow, minValTop, maxValTop)
% GENERATE_VAR_REPORT

import mperl.file.spec.catfile;
import shadederrorbar.shadederrorbar;
import misc.unique_filename;
import rotateticklabel.rotateticklabel;
import plot2svg.plot2svg;
import report.gallery.gallery;
import goo.globals;
import inkscape.svg2png;
import misc.print;

%% Initialize the gallery of images
myGallery   = gallery(...
    'Title',   'Data variance across data samples', ...
    'Level',   get_level(rep) + 1, ...
    'NoLinks', true);

% Should the generated figures be visible?
visible = globals.get.VisibleFigures;
if visible,
    visible = 'on';
else
    visible = 'off';
end

%% Convert quantities to dB
if any(lowVar > eps),
    
    mm = min(lowVar(lowVar > eps));
    lowVar(lowVar>eps) = 10*log10(lowVar(lowVar>eps));
    
    if any(lowVar < eps),
       
        lowVar(lowVar < eps) = mm - 20;
       
    end
    
    if minValLow < eps,
        minValLow = mm - 10;
    else
        minValLow = 10*log10(minValLow);
    end
    if maxValLow < eps,
        maxValLow = mm - 10;
    else
        maxValLow = 10*log10(maxValLow);
    end
end

if any(topVar > eps),
    
    mm = min(topVar(topVar > eps));
    topVar(topVar>eps) = 10*log10(topVar(topVar>eps));
    
    if any(topVar < eps),
        topVar(topVar < eps) = mm - 20;
    end
    
end

if minValTop < eps,
    minValTop = mm - 10;
else
    minValTop = 10*log10(minValTop);
end

if maxValTop < eps,
    maxValTop = mm - 10;
else
    maxValTop = 10*log10(maxValTop);
end

%% Generate the low variance plot

figure('Visible', visible);
plot(lowVar, 'k');

grid on;
axis tight;
yLims    = get(gca, 'YLim');
xLims    = get(gca, 'XLim');
yRange   = abs(diff(yLims));
yLims(1) = yLims(1) - 0.1*yRange;
yLims(2) = yLims(2) + 0.1*yRange;
set(gca, 'YLim', yLims);
ylabel('Lower quartile window variance (dB)');
xlabel('Time (samples)');
set(gca, 'FontSize', 8);

if all(lowVar > minValLow)
    minValLow = yLims(1);
end

if all(lowVar < maxValLow)
    maxValLow = yLims(2);
end

hold on;

h = patch([xLims xLims(2) xLims(1)], ...
    [minValLow minValLow maxValLow maxValLow], ...
    [0.5 1 0]);

set(h,  ...
    'LineStyle',    'none', ...
    'FaceAlpha',    0.2, ...
    'EdgeAlpha',    0.2);

if any(isRej),
    
    hold on;
    lowIsRej = isRej & (lowVar > maxValLow | lowVar < minValLow);
    value = nan(1,numel(isRej));
    value(lowIsRej) = lowVar(lowIsRej);
    plot(value, 'r');
    
end

% Print to .svg and .png format
fileName = catfile(get_rootpath(rep), 'lowvar-plot.svg');
fileName = unique_filename(fileName);

caption     = sprintf(...
    [ ...
    'Lower quartile data variance across time. Magenta lines are ' ...
    'upper and lower rejection thresholds. Rejected samples (if any) ' ...
    'are marked in red.' ...
    ]);

[path, name] = fileparts(fileName);

evalc('plot2svg(fileName, gcf);');
myGallery   = add_figure(myGallery, fileName, caption);

% For the thumbnails, we always need a .png
% But we cannot do this with -nodisplay because there is not any valid
% renderer for transparent figures -> MATLAB crashes badly
%if usejava('Desktop'),
%    print('-dpng', [catfile(path, name) '.png'], '-r600'); 
%else
% USE ALWAYS inkscape: more robust. Otherwise this also crashes when
% running MATLAB under a VM
svg2png(fileName);
%end

myGallery   = add_figure(myGallery, [catfile(path, name) '.png'], caption);

close;


%% Generate the top variance plot
figure('Visible', visible);
plot(topVar, 'k');

grid on;
axis tight;
yLims    = get(gca, 'YLim');
xLims    = get(gca, 'XLim');
yRange   = abs(diff(yLims));
yLims(1) = yLims(1) - 0.1*yRange;
yLims(2) = yLims(2) + 0.1*yRange;
set(gca, 'YLim', yLims);
ylabel('Upper quartile window variance (dB)');
xlabel('Time (samples)');
set(gca, 'FontSize', 8);

if all(topVar > minValTop)
    minValTop = yLims(1);
end

if all(topVar < maxValTop)
    maxValTop = yLims(1);
end

hold on;

h = patch([xLims xLims(2) xLims(1)], ...
    [minValTop minValTop maxValTop maxValTop], ...
    [0.5 1 0]);

set(h,  ...
    'LineStyle',    'none', ...
    'FaceAlpha',    0.2, ...
    'EdgeAlpha',    0.2);

if any(isRej),
    
    hold on;
    topIsRej = isRej & (topVar > maxValTop | topVar < minValTop);
    value = nan(1, numel(isRej));
    value(topIsRej) = topVar(topIsRej);
    plot(value, 'r');
    
end

% Print to .svg and .png format
fileName = catfile(get_rootpath(rep), 'topvar-plot.svg');
fileName = unique_filename(fileName);

caption     = sprintf(...
    [ ...
    'Upper quartile data variance across time. Transparent green area is ' ...
    'between upper and lower rejection thresholds. Rejected samples ' ...
    'are marked in red. Non-relevant thresholds are not plotted for ' ...
    'clarity' ...
    ]);

%[path, name] = fileparts(fileName);

evalc('plot2svg(fileName, gcf);');
myGallery   = add_figure(myGallery, fileName, caption);

% For the thumbnails, we always need a .png
% But we cannot do this with -nodisplay because there is not any valid
% renderer for transparent figures -> MATLAB crashes badly
% if usejava('Desktop'),
%     print('-dpng', [catfile(path, name) '.png'], '-r600');
% else
svg2png(fileName);
% end

close;


%% Print a gallery
fprintf(rep, myGallery);


end