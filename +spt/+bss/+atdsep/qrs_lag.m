function tau = qrs_lag(~, ev, varargin)


import pset.event.class_selector;

evSel = class_selector('qrs');
ev = select(evSel, ev);
if ~isempty(ev),
    sample = get_sample(ev);
    
    if numel(sample) > 10,
        tau = (median(sample)-mads(samples)):(median(sample)+mads(sample));
    else
        tau = median(sample);
    end
else
    tau = [0 1];
    
end

end