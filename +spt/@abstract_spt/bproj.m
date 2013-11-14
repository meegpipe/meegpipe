function [y, I] = bproj(obj, data)


A = bprojmat(obj);

y = A*data;

I = dim_selection(obj);

if isa(y, 'physioset.physioset'),
    restore_sensors(data);
end


end