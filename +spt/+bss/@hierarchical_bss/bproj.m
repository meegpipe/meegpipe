function [y, I] = bproj(obj, ics)


A        = bprojmat_win(obj);
I        = dim_selection(obj);
Ic       = component_selection(obj);
winBndry = window_boundary(obj);

y = pset.pset.nan(nb_dim(obj), size(ics,2));

if isa(ics, 'physioset.physioset')
    y = physioset.physioset.from_pset(y, ...
        'SamplingRate',     ics.SamplingRate, ...
        'Sensors',          ics.Sensors, ...
        'Event',            ics.Event, ...
        'StartDate',        ics.StartDate, ...
        'StartTime',        ics.StartTime);
    
    copy_sensors_history(y, ics);
end

select(ics, Ic);
for i = 1:size(A,3)
    timeRange = winBndry(i,1):winBndry(i,2);
    select(ics, [], timeRange);
    y(:, timeRange) = squeeze(A(:,:,i))*ics(:,:);
    restore_selection(ics);
end
restore_selection(ics);

if isa(ics, 'physioset.physioset'),
    restore_sensors(y, obj);
end


end