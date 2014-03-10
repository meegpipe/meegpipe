function [featVal, featName] = extract_feature(obj, sptObj, ~, data, varargin)

NB_NEAREST = 5;

featName = [];

sens = sensors(data);
xyz  = cartesian_coords(sens);
 
maxY = max(xyz(:,2));

isFront = xyz(:,2) >= obj.R0*maxY & xyz(:,2) <= obj.R1*maxY;

Mraw = bprojmat(sptObj).^2;
if size(data,1) > 20 && has_coords(sens),
    dist = euclidean_dist(sens);
    Mf = Mraw;
    for i = 1:size(Mraw,2)
        for j = 1:size(Mraw,1)
            if ~isFront(j), continue; end
            thisDist = dist(j, :);
            [~, idx] = sort(thisDist, 'ascend');
            nearestIdx = idx(1:min(NB_NEAREST, numel(idx)));
            Mf(j, i) = median(Mraw(nearestIdx, i));
        end
    end
    M = Mf;
else
    M = Mraw;
end

M = misc.unit_norm(M);

featVal = sum(M(isFront,:))./sum(M(~isFront,:));


end