function [data, dataNew] = process(obj, data, varargin)

import physioset.plotter.snapshots.snapshots;
import physioset.event.std.ecg_ann;
import goo.globals;
import misc.eta;
import meegpipe.node.ecg_annotate.ecg_annotate;
import cardiac_output.wabp;
import meegpipe.node.abp.abp;

dataNew = [];

verbose      = is_verbose(obj);
verboseLabel = get_verbose_label(obj);
origVerboseLabel = globals.get.VerboseLabel;
origVerbose      = globals.get.Verbose;
globals.set('VerboseLabel', verboseLabel);
globals.set('Verbose', verbose);

if is_verbose(obj),
    fprintf([verboseLabel 'Extracting ABP features ...\n\n']);
end

[featNames, featVals] = abp.extract_features(data);

featFile = 'features.txt';
if verbose,
    fprintf([verboseLabel, ...
        'Saving ABP features to %s ...'], featFile);
end

fid = get_log(obj, featFile);

% Print a header and the data values
formatStr = repmat('%s,', 1, numel(featNames));
formatStr = [formatStr(1:end-1) '\n'];
fprintf(fid, formatStr, featNames{:});

formatStr = repmat('%5.3f,', 1, numel(featNames));
formatStr(end) = [];

fprintf(fid, formatStr, featVals);

if verbose, fprintf('[done]\n\n'); end

rep = get_report(obj);
print_title(rep, 'ABP feature extraction report', get_level(rep)+1);
print_paragraph(rep, 'ABP features: [features.txt][features]');
print_link(rep, '../features.txt', 'features');


globals.set('VerboseLabel', origVerboseLabel);
globals.set('Verbose', origVerbose);

end