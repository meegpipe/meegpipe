function H = mdfilt(obj)
% MDFILT - Conversion to MATLAB's dfilt.?? class
%

if ~isempty(obj.MDFilt),
    H = obj.MDFilt;
    return;
end

if isempty(obj.LpFilter),
    H = [];
    return;
end

H = cell(1, numel(obj.LpFilter));
persistentMem = false;

count = 0;
for bandItr = 1:numel(obj.LpFilter)
    
    if isempty(obj.LpFilter{bandItr}) && isempty(obj.HpFilter{bandItr}),
        
        continue;
        
    elseif isempty(obj.HpFilter{bandItr}),
        
        count = count + 1;
        H{count} = mdfilt(obj.LpFilter{bandItr});
        persistentMem = persistentMem || ...
            obj.LpFilter{bandItr}.PersistentMemory;
        
        
    elseif isempty(obj.LpFilter{bandItr}),
        
        count = count + 1;
        H{count} = mdfilt(obj.HpFilter{bandItr});
        persistentMem = persistentMem || ...
            obj.HpFilter{bandItr}.PersistentMemory;
        
    else
        
        count = count + 1;
        H{count} = cascade(...
            mdfilt(obj.LpFilter{bandItr}), ...
            mdfilt(obj.HpFilter{bandItr}));
        
        persistentMem = persistentMem || ...
            obj.HpFilter{bandItr}.PersistentMemory || ...
            obj.LpFilter{bandItr}.PersistentMemory;
        
        
    end
    
end

H = H(1:count);

if numel(H) > 1,
    H = parallel(H{:});
else
    H = H{1};
end

end