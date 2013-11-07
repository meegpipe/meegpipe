function [data, dataNew] = process(obj, data, varargin)


import fmrib.my_fmrib_qrsdetect;
import meegpipe.node.qrs_detect.qrs_detect;
import physioset.plotter.snapshots.snapshots;

dataNew= [];

verboseLabel = get_verbose_label(obj);

if is_verbose(obj),
    fprintf([verboseLabel 'Running fmrib''s QRS detection algorithm...\n\n']);
end

if size(data, 1) > 1,
    error('A single ECG channel is expected');
end

detector = get_config(obj, 'Detector');
sample = detector(data(:,:), data.SamplingRate);

logFile = [get_name(data) '_qrs_pos.log'];
fid = get_log(obj, logFile);

if isempty(sample), return; end

if fid.Valid,
    fprintf(fid, '%d\n', sample);
else
    warning('qrs_detect:LogWrite', ...
        'I could not write to log file ''%s''', logFile);
end

event = get_config(obj, 'Event');

if isa(event, 'function_handle'),
    evArray = event(sample);
else
    evArray = repmat(event, 1, numel(sample));
    evArray = set_sample(evArray, sample);
end

add_event(data, evArray);

if is_verbose(obj),
    fprintf(['\n\n' verboseLabel ...
        'Done with fmrib''s QRS detection algorithm\n\n']);
end

if do_reporting(obj),
    
    if is_verbose(obj),
        fprintf([verboseLabel 'Generating report...']);
    end
    
    rep = get_report(obj);
    print_title(rep, 'QRS detection report', get_level(rep)+1);
    
    % Plot some snapshots
    snapshotPlotter = snapshots('WinLength', 10);
    
    plotterRep = report.plotter.plotter('Plotter', snapshotPlotter);
    
    plotterRep = embed(plotterRep, rep);
    
    generate(plotterRep, data);
    
    if is_verbose(obj),
        fprintf('[done]\n\n');
    end
    
end



end