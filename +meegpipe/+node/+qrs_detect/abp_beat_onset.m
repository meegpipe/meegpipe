function myNode = abp_beat_onset(varargin)

import meegpipe.node.*;

detector = @(data) cardiac_output.wabp(resample(data(1,:), ...
    data.SamplingRate, 125));

eventFh = @(sampl) physioset.event.event(sampl, 'Type', '__BeatOnset');

dataSel = pset.selector.sensor_label('^BP');

myNode = qrs_detect.new(...
    'DataSelector', dataSel, ...
    'Name',         'abp_beat_onset', ...
    'Detector',     detector, ... 
    'Event',        eventFh);
    

end