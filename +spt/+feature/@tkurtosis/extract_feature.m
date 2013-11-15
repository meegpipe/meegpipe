function featVal = extract_feature(obj, ~, tSeries, varargin)

featVal = nan(1, size(tSeries,1));

for i = 1:size(tSeries,1)
    this = tSeries(i,:);    
    if obj.MedFiltOrder > 1,
        this = medfilt1(this, obj.MedFiltOrder);        
    end
    this = this./sqrt(var(this));
    featVal(i) = kurtosis(this, 1, 2);
end

end