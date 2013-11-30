function [bssArray, winBndry] = learn_lr_basis(obj, data, parentBSS, winBndryIn)

import spt.distance;

verbLevel    = get_verbose_level(obj);
verboseLabel = get_verbose_label(obj);

maxWindowLength = obj.MaxWindowLength;
if isa(maxWindowLength, 'function_handle'),
    maxWindowLength = maxWindowLength(data.SamplingRate);
end

if diff(winBndryIn) < maxWindowLength
    bssArray = {parentBSS};
    winBndry = winBndryIn;
    return;
end

select(data, [], winBndryIn(1):winBndryIn(2));

childrenDist   = Inf;
overlapCounter = 0;

while overlapCounter < numel(obj.Overlap) && ...
        childrenDist > obj.DistanceThreshold
    
    overlapCounter = overlapCounter + 1;
    
    leftEnd    = floor((1+obj.Overlap(overlapCounter)/100)*size(data,2)/2);
    rightBegin = ceil((1-obj.Overlap(overlapCounter)/100)*size(data,2)/2);
    winBndry   = [...
        winBndryIn(1) winBndryIn(1)+floor(size(data,2)/2);...
        winBndryIn(1)+floor(size(data,2)/2)+1 winBndryIn(2)];
    
    dataLeft  = data(:, 1:leftEnd);
    dataRight = data(:, rightBegin:end);
    
    bssLeft  = cell(1, obj.ChildrenSurrogates);
    bssRight = cell(1, obj.ChildrenSurrogates);
    
    if verbLevel > 0,
        fprintf([verboseLabel ...
            'Learning %s basis from %d surrogates on two windows ' ...
            '(L=%d samples, %d%% overlap) ...'], class(obj.BSS), ...
            obj.ChildrenSurrogates, leftEnd, ...
            round(obj.Overlap(overlapCounter)));
    end
    
    tinit = tic;
    surrogator = obj.Surrogator;
    
    for surrIter = 1:obj.ChildrenSurrogates
        
        surrogator = set_seed(surrogator, get_seed(obj) + surrIter*100);
        dataSurr = surrogate(surrogator, dataLeft);
        bssLeft{surrIter} = learn(parentBSS, dataSurr);
        bssLeft{surrIter} = match_sources(bssLeft{surrIter}, eye(nb_dim(parentBSS)));
        bssLeft{surrIter} = cascade(parentBSS, bssLeft{surrIter});        
        
        dataSurr = surrogate(surrogator, dataRight);
        bssRight{surrIter} = learn(parentBSS, dataSurr);
        bssRight{surrIter}  = match_sources(bssRight{surrIter}, eye(nb_dim(parentBSS)));
        bssRight{surrIter} = cascade(parentBSS, bssRight{surrIter});
        if verbLevel > 0
            misc.eta(tinit, obj.ChildrenSurrogates, surrIter);
        end
    end   
    
    
    % Eliminate those estimates too far from the centroid
    distVal = distance({parentBSS}, bssRight, obj.DistanceMeasure);
    minRightDist = min(distVal);
    
    bssRight(distVal > obj.DistanceThreshold) = [];
    
    distVal = distance({parentBSS}, bssLeft, obj.DistanceMeasure);
    minLeftDist = min(distVal);
    bssLeft(distVal > obj.DistanceThreshold) = [];
    
    if verbLevel > 0,
        fprintf('[minLeftDist=%.2f, minRightDist=%.2f]\n\n', ...
            minLeftDist, minRightDist);
    end
    
    % Now pick the closest left/right decomposition
    if isempty(bssLeft) || isempty(bssRight),
        childrenDist = Inf;
    else
        distVal = distance(bssLeft, bssRight, obj.DistanceMeasure);
        [childrenDist, I] = min(distVal(:));
        [i,j]  = ind2sub(size(distVal), I);
        bssLeft  = bssLeft{i};
        bssRight = bssRight{j};             
    end
    
end
restore_selection(data);

if childrenDist > obj.DistanceThreshold,
    % Could not find two similar-enough decompositions: use parent
    winBndry = winBndryIn;
    bssArray = {parentBSS};
else
    select(data, [], winBndry(1,1):winBndry(1,2));
    proj(bssLeft, data);
    restore_selection(data);
    select(data, [], winBndry(2,1):winBndry(2,2));
    proj(bssRight, data);
    restore_selection(data);
    
    % Recursively call on learn_lr_basis
    [bssLeft, winLeft]  = learn_lr_basis(obj, data, bssLeft, winBndry(1,:));
    [bssRight, winRight] = learn_lr_basis(obj, data, bssRight, winBndry(2,:));
    bssArray = [bssLeft, bssRight];
    winBndry = [winLeft;winRight];
end

end