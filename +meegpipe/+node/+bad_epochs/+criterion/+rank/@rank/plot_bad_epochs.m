function plot_bad_epochs(rep, rejIdx, data, ev)

import mperl.join;

NB_CHANS  = 10;
NB_EPOCHS = 4;

if isempty(ev) || isempty(rejIdx),
    return;
end

chanIdx  = unique(ceil(linspace(1, size(data, 1), NB_CHANS)));
epochIdx = unique(ceil(linspace(1, numel(rejIdx), NB_EPOCHS)));
epochIdx = rejIdx(epochIdx);

epochRanges     = nan(numel(epochIdx), 2);
plotEpochRanges = nan(numel(epochIdx), 2);

for i = 1:numel(epochIdx)
    epochRanges(i, 1) = get(ev(epochIdx(i)), 'Sample');
    epochRanges(i, 2) = epochRanges(i, 1) + ...
        get(ev(epochIdx(i)), 'Duration')-1;
    
    Delta = diff(epochRanges(i,:));
    plotEpochRanges(i, 1) = max(1, epochRanges(i,1)-Delta);
    plotEpochRanges(i, 2) = min(size(data,2), epochRanges(i,2)+Delta);
end

plotterObj = physioset.plotter.snapshots.new(...
    'Channels',     chanIdx, ...
    'NbGoodEpochs', 1, ...
    'NbBadEpochs',  0, ...
    'Epochs',       plotEpochRanges);

subRep = report.plotter.new(...
    'Plotter',     plotterObj, ...
    'Title',       'Sample bad epochs');
    
embed(subRep, rep);

print_title(rep, 'Sample Bad Epochs', get_level(rep) + 1);

print_paragraph(rep, 'Plotting epochs %s', join(',', epochIdx));

set_level(subRep, get_level(rep) + 2);

generate(subRep, data);

end