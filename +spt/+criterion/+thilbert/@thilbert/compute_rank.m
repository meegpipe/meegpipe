function rankValue = compute_rank(~, ~, tSeries, varargin)

tSeries = tSeries - repmat(mean(tSeries, 2), 1, size(tSeries,2));
for i = 1:size(tSeries,1),
    tSeries(i,:) = tSeries(i,:)./sqrt(var(tSeries(i,:)));
end

envelope = abs(hilbert(tSeries'));

rankValue = var(envelope);
rankValue(rankValue < eps) = eps;
rankValue = 1./rankValue(:);


end