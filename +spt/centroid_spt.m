function [bssCentroid, centroidIdx, distVal] = centroid_spt(bssArray, distMeas)


dMat = nan(numel(bssArray));

for i = 1:numel(bssArray)
    for j = 1:numel(bssArray),
        if i == j, continue; end
        dMat(i,j) = distMeas(bssArray{i}, bssArray{j});
    end
end

[~, centroidIdx] = min(nanmean(dMat));

bssCentroid = bssArray{centroidIdx};

distVal = dMat(centroidIdx,:);
distVal(centroidIdx) = 0;


end