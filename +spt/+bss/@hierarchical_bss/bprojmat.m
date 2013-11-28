function A = bprojmat(obj, varargin)

A = cell(1, numel(obj.BSSwin));

for i = 1:numel(obj.BSSwin)
   A{i} = bprojmat(obj.BSSwin{i}, varargin); 
end

if numel(A) == 1,
    A = A{1};
end

end