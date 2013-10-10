function [data, dataNew] = process(obj, data, varargin)
% PROCESS - Interpolates bad channels
%
% data = process(obj, data)
%
% Where
%
% DATA is a physioset object
%
%
% See also: physioset, bad_channels


import mperl.join;
import report.generic.generic;
import report.object.object;
import meegpipe.node.bad_channels.bad_channels;
import meegpipe.node.globals;
import misc.euclidean_dist;

dataNew = [];

verbose = is_verbose(obj);
verboseLabel = get_verbose_label(obj);

nn   = get_config(obj, 'NN');

% List of bad channels
badIdx  = find(is_bad_channel(data));
goodIdx = find(~is_bad_channel(data));

if isempty(badIdx),
    warning('chan_itern:NoBadChans', ...
        'There are no bad channels: no need to interpolate');
    return;
end

if numel(goodIdx) < nn,
    error('chan_itern:NoGoodChans', ...
        ['%d channels were requested for interpolation but there are ' ...
        'only %d good channels'], numel(goodIdx));
end

sens  = sensors(data); 
xyz   = sens.Cartesian;


W = zeros(size(data,1));
chanGroups = cell(1, numel(badIdx));

for i = 1:numel(badIdx)
   % Find nearest neighbors
   dist = euclidean_dist(xyz(badIdx(i),:), xyz(goodIdx,:));
   [nnDist, nnIdx] = sort(dist, 'ascend');
   weights = 1./nnDist(1:nn);
   weights = weights/sum(weights);
   data(badIdx(i),:) = weights'*data(goodIdx(nnIdx(1:nn)),:);   
   W(badIdx(i), goodIdx(nnIdx(1:nn))) = weights;
   
   if do_reporting(obj),
       nearestChans = goodIdx(nnIdx(1:nn));
       chanGroups{i} = sort([badIdx(i);nearestChans(:)], 'ascend');
   end
   
end

if verbose,
    
    fprintf([verboseLabel ...
        'Interpolated %d channels using %d nearest neighbors\n\n'], ...
        numel(badIdx), nn);
    
end

if do_reporting(obj)
    if verbose
        fprintf( [verboseLabel, 'Generating interpolation report ...']);
    end
    rep = get_report(obj);
    print_title(rep, 'Interpolation report', get_level(rep) + 1);    
    
    snapshotPlotter = physioset.plotter.snapshots.new(...
        'MaxChannels',      Inf, ...
        'WinLength',        20, ...
        'NbBadEpochs',      0, ...
        'NbGoodEpochs',     2, ...
        'Channels',         chanGroups);
    
    snapshotRep = report.plotter.new(...
        'Plotter',              snapshotPlotter, ...
        'Title',                'Interpolation snapshots', ...
        'PrintGalleryTitle',    false);
    
    embed(snapshotRep, rep);
    
    print_paragraph(snapshotRep, [...
        'Interpolated channels plotted together with the %d nearest ' ...
        'neighbours that were used as ' ...
        'reference for the interpolation'], nn);   
    
    set_level(snapshotRep, get_level(rep) + 2);
    
    generate(snapshotRep, data);
    
    if verbose, fprintf('[done]\n\n'); end
end


end