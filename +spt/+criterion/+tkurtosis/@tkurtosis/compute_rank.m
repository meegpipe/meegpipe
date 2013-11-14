function rankValue = compute_rank(obj, ~, tSeries, varargin)


medFiltOrder = get_config(obj, 'MedFiltOrder');
filtObj      = get_config(obj, 'Filter');

if medFiltOrder > 1,
    tSeries = medfilt1(tSeries', medFiltOrder)';
end

if ~isempty(filtObj),
    tSeries = filter(filtObj, tSeries);
end

for i = 1:size(tSeries,1)
    tSeries(i,:) = tSeries(i,:)./sqrt(var(tSeries(i,:)));
end

rankValue = kurtosis(tSeries, 1, 2);


end