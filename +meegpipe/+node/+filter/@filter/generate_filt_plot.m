function gal = generate_filt_plot(rep, idx, data1, data2, samplTime, ...
    gal, showDiff)


import meegpipe.node.globals;
import mperl.file.spec.catfile;
import misc.unique_filename;
import plot2svg.plot2svg;
import inkscape.svg2png;
import misc.resample;

% Maximum length in point of the time series that will be plotted
MAX_LENGTH = 50000;

if nargin < 6 || isempty(gal),
    % Start a new gallery
    gal = clone(globals.get.Gallery);
end

% IMPORTANT: The current statble version of Inkscape (0.48.2) crashes when
% attempting to convert very large .svg files to .png. The downsampling 
% here is to prevent the inkscape crash, but anyways it's a good idea to
% downsample for making the svg to png conversion faster. 
Q = ceil(size(data1,2)/MAX_LENGTH);
data1 = resample(data1(:,:), 1, Q);
data2 = resample(data2(:,:), 1, Q);
samplTime = samplTime(1:Q:end);

plot(samplTime, data1, 'k', 'LineWidth', globals.get.LineWidth);
hold on;

if showDiff,
    plot(samplTime, data1-data2, 'r', ...
        'LineWidth', 0.75*globals.get.LineWidth);
else
    plot(samplTime, data2, 'r', 'LineWidth', 0.75*globals.get.LineWidth);
end

xlabel('Time from beginning of recording (s)');
ylabel(['Channel ' num2str(idx)]);

% Print to .svg and .png format
rootPath = get_rootpath(rep);
fileName = catfile(rootPath, ['filt-report-channel' num2str(idx) '.svg']);
fileName = unique_filename(fileName);

if showDiff,
    caption = ['Raw data (black), and input/output difference (red) ' ...
        'for channel ' num2str(idx)];
else
    caption = ['Raw data (black) and filter output (red) for channel ' ...
        num2str(idx)];
end

evalc('plot2svg(fileName, gcf);');
svg2png(fileName);

close;

gal = add_figure(gal, fileName, caption);



end