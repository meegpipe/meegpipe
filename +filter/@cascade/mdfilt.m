function H = mdfilt(obj)
% MDFILT - Conversion to MATLAB's dfilt.?? class
%

if ~isempty(obj.MDFilt),
    H = obj.MDFilt;
    return;
end

if isempty(obj.Filter),
    H = [];
    return;
end

filterArray = obj.Filter;

for i = 1:numel(filterArray)
    filterArray{i} = mdfilt(filterArray{i});
end

H = cascade(filterArray{:});
H.PersistentMemory = obj.Filter{1}.PersistentMemory;


end