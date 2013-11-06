function featVal = co(data, sr)

if size(data,1) > 1,
    warning('abp:MultipleABPleads', ...
        '%d ABP leads found: using only the first one', size(data,1));
end

coFeat = co_features(data(1,:), sr);

featVal = coFeat(9);



end