function W = projmat(obj, varargin)

W = cell(1, numel(obj.BSSwin));

for i = 1:numel(obj.BSSwin)
   W{i} = projmat(obj.BSSwin{i}, varargin); 
end

if numel(W) == 1,
    W = W{1};
end

end