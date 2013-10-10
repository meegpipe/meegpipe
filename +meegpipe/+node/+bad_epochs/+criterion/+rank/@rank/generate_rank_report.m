function generate_rank_report(rep, rankIndex, rejIdx, minRank, maxRank)

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

%% Rank values and rejection thresholds
if verbose,
    fprintf([verboseLabel ...
        'Plotting rank values across channels...']);
end

rank.make_rank_plots(rankIndex, rejIdx, minRank, maxRank);

% Print to .svg and .png format
fileName = catfile(get_rootpath(rep), 'epoch_ranks.svg');
fileName = unique_filename(fileName);

caption = sprintf('Rejection criterion values across epochs');

% IMPORTANT: Print to png AFTER printing to svg. For some reason, printing
% to .png during terminal mode emulation screws the figures looks!
evalc('plot2svg(fileName, gcf);');
myGallery = add_figure(myGallery, fileName, caption);

svg2png(fileName);

close;

if verbose, fprintf('[done]\n\n'); end

fprintf(rep, myGallery);

end