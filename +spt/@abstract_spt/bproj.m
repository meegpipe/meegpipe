function [y, I] = bproj(obj, data)


A = bprojmat(obj);
I = dim_selection(obj);
Ic = component_selection(obj);

select(data, Ic);
y = A*data;
restore_selection(data);

if isa(y, 'physioset.physioset'),
    restore_sensors(data, obj);
end


end