function [y, I] = bproj(obj, data, fullMatrix)

if nargin < 3 || isempty(fullMatrix), fullMatrix = false; end

A = bprojmat(obj, fullMatrix);

if fullMatrix,
    I = size(A,1);
else
    I = dim_selection(obj);
end
Ic = component_selection(obj);

if ~fullMatrix,
    select(data, Ic);
end
y = A*data;
if ~fullMatrix,
    restore_selection(data);
end

if isa(y, 'physioset.physioset'),
    restore_sensors(data, obj);
end


end