function rankValue = compute_rank(obj, sptObj, tSeries, sr, ev, rep, data, varargin)



import misc.process_arguments;
import misc.euclidean_dist;
import misc.unit_norm;

if size(tSeries, 1) == 1,
    rankValue = 1;
    return;
end

sptObj = clear_selection(sptObj);

% Components to use a gold standard
criterion = get_config(obj, 'Criterion');
idx = find(select(criterion, sptObj, tSeries, sr, ev, rep, data, varargin{:}));

% Only sensors with valid coordinates will be considered
A    = abs(bprojmat(sptObj));
sens = sensors(data);
xyz  = cartesian_coords(sens);
if all(isnan(xyz)),
    error('stopo2:MissingCoordinates', ...
        'The stopo2 criterion requires sensor coordinates to be known');  
elseif any(isnan(xyz)),
    warning('stopo2:MissingCoordinates', ...
        ['The stopo2 criterion requires sensor coordinates: ignoring %d ' ...
        'sensor(s) with missing coordinates'], numel(find(isnan(xyz(:,1)))));
    A(isnan(xyz(:,1)), :)   = [];
    xyz(isnan(xyz(:,1)), :) = [];
end
A = unit_norm(A);

% Find the top energy channels for each topo

rankValue = zeros(1, size(A,2));
nbChans = round(0.05*size(A,1));
if nbChans < 1,
    nbChans = 1;
end
topChans = nan(nbChans, size(A,2));
for i = 1:size(A,2)
    vals = abs(A(:,i));
    [~, sortedIdx] = sort(vals, 'descend');
    topChans(:,i) = sortedIdx(1:nbChans);
end


for i = 1:size(A,2)
    
    thisXYZ  = xyz(topChans(:,i),:);
    
    if all(isnan(thisXYZ)),
        rankValue(i) = 0;
        continue;
    end
    weights  = A(topChans(:, i));
    tmp = inf(1, numel(idx));
    
    for j = 1:numel(idx)
        templTopChans = topChans(:, idx(j));
        refXYZ = xyz(templTopChans, :);
        
        % Average distance between this channel top chans and template top
        % chans
        thisMinDist = 0;
        for k = 1:nbChans,
            
            thisDist = euclidean_dist(thisXYZ(k,:), refXYZ);
            
            thisMinDist = thisMinDist + weights(k)*min(thisDist);
            
        end
        tmp(j) = min(tmp(j), thisMinDist);
    end
    rankValue(i) = rankValue(i) + min(tmp);
    
end

rankValue(isnan(rankValue)) = 0;

rankValue = 1./rankValue;
if all(isinf(rankValue)),
    rankValue = zeros(size(rankValue));
    rankValue(idx) = 1;    
elseif any(isinf(rankValue)),
    rankValue(isinf(rankValue)) = 2*max(rankValue(~isinf(rankValue)));
end

end