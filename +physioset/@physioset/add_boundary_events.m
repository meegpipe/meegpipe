function [obj, evIdx] = add_boundary_events(obj)

winrej = eeglab_winrej(obj);

evIdx = nan(1, size(winrej,1));
count = 0;

% Get already existing events (to avoid adding duplicates)
ev = get_event(obj);
existingEvSampl = [];
if ~isempty(ev),
    ev = select(ev, 'Type', 'boundary');
    if ~isempty(ev),
        existingEvSampl = get_sample(ev);
    end
end

for i = 1:size(winrej,1)
    pos = winrej(i,1);
    if pos < 1, continue; end
    if ismember(pos, existingEvSampl), continue; end
    dur = diff(winrej(i,1:2))+1;
    samplTime = get_sampling_time(obj);
    lat = samplTime(pos);
    thisEv = physioset.event.new(pos, 'Type', 'boundary', 'Time', lat, ...
        'Duration', 1, 'Value', dur);
    
    [~, evIdx(i)] = add_event(obj, thisEv);
    count = count + 1;
end
evIdx(count+1:end) = [];

end