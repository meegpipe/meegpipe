function generate_rank_report(rep, rankIndex, rejIdx, minRank, maxRank, rankStats)

import meegpipe.node.bad_epochs.criterion.rank.rank;
import inkscape.svg2png;
import plot2svg.plot2svg;
import report.gallery.gallery;
import misc.unique_filename;
import mperl.file.spec.catfile;

verbose         = is_verbose(rep);
verboseLabel    = get_verbose_label(rep);
verboseLabel    = [verboseLabel '    '];

myGallery       = gallery;


if verbose,
    fprintf([verboseLabel ...
        'Plotting rank values across channels...']);
end

%% Plot rank values versus epoch index
hFig = rank.plot_epoch_vs_rank(rankIndex, rejIdx, minRank, maxRank, rankStats); %#ok<NASGU>

% Print to .svg and .png format
fileName = catfile(get_rootpath(rep), 'epoch_ranks.svg');
fileName = unique_filename(fileName);

caption = sprintf('Rejection criterion values across epochs');

% IMPORTANT: Print to png AFTER printing to svg. For some reason, printing
% to .png during terminal mode emulation screws the figures looks!
evalc('plot2svg(fileName, hFig);');
myGallery = add_figure(myGallery, fileName, caption);

svg2png(fileName);

close;

%% Plot PDF of rank values
hFig = rank.plot_rank_pdf(rankIndex, rejIdx, minRank, maxRank, rankStats); %#ok<NASGU>

% Print to .svg and .png format
fileName = catfile(get_rootpath(rep), 'ranks_pdf.svg');
fileName = unique_filename(fileName);

caption = sprintf('PDF for the epoch rejection criterion values');

% IMPORTANT: Print to png AFTER printing to svg. For some reason, printing
% to .png during terminal mode emulation screws the figures looks!
evalc('plot2svg(fileName, hFig);');
myGallery = add_figure(myGallery, fileName, caption);

svg2png(fileName);

close;


if verbose, fprintf('[done]\n\n'); end

fprintf(rep, myGallery);

end