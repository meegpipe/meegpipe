function rankValue = compute_rank(obj, sptObj, tSeries, varargin)



import misc.process_arguments;
import misc.unit_norm;

sptObj = clear_selection(sptObj);
A      = unit_norm(bprojmat(sptObj));

% Components to use a gold standard
criterion = get_config(obj, 'Criterion');
idx = find(select(criterion, sptObj, tSeries, varargin{:}));

A = abs(A);
% Find the 90% sensor set for these gold standard EOG artifacts
sensorSetHigh = [];
for i = 1:numel(idx),
    sensorSetHigh = union(sensorSetHigh, ...
        find(A(:, idx(i)) > prctile(A(:,idx(i)),90)));
end

% Find the 10% sensor set for these gold standard EOG artifacts
sensorSetLow = [];
for i = 1:numel(idx),
    sensorSetLow = union(sensorSetLow, ...
        find(A(:, idx(i)) < prctile(A(:,idx(i)),10)));
end

rankValue = NaN(1, size(tSeries, 1));
for i = 1:size(tSeries,1)
    thisSensorSetHigh = find(A(:, i) > prctile(A(:, i), 90));
    thisSensorSetLow  = find(A(:, i) < prctile(A(:, i), 10));
    rankValue(i) = numel(intersect(thisSensorSetHigh, sensorSetHigh)) + ...
        numel(intersect(thisSensorSetLow, sensorSetLow));
end


end