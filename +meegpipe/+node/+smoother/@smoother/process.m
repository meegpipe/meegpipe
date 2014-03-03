function [data, dataNew] = process(obj, data, varargin)

import physioset.event.class_selector;

dataNew = [];

mergeWindow = get_config(obj, 'MergeWindow');
mergeWindow = ceil(mergeWindow*data.SamplingRate);

eventSelector = get_config(obj, 'EventSelector');
eventArray = select(eventSelector, get_event(data));

verboseLabel = get_verbose_label(obj);
verbose = is_verbose(obj);

if isempty(eventArray), 
    if verbose,
        fprintf([verboseLabel 'No discontinuity events: skipping smoothing\n\n']);
    end
    return; 
end

eventArray = set_offset(eventArray, -mergeWindow);
eventArray = set_duration(eventArray, 2*mergeWindow+1);

 
if is_verbose(obj),
    
    verboseLabel = get_verbose_label(obj);
    
    fprintf( [verboseLabel 'Smoothing ''%s''...'], get_name(data));
    
end

data = smooth_transitions(data, eventArray);

if is_verbose(obj)
    
   fprintf('[done]\n\n');
   
end

end