function [y, I] = proj(obj, data)


W = projmat(obj);

if isa(data, 'physioset.physioset'),
    backup_sensors(data);
end

y = W*data;

I = component_selection(obj);


end