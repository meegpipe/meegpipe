function [data, dataNew] = process(obj, data, varargin)


dataNew = [];

verboseLabel = get_verbose_label(obj);
verbose = is_verbose(obj);


% Configuration options
targetSelector  = get_config(obj, 'TargetSelector');
firstLevel      = get_config(obj, 'FirstLevel');
secondLevel     = get_config(obj, 'SecondLevel');
featNames       = get_config(obj, 'FeatureNames');


firstLevelFeats = nan(1, numel(targetSelector));
for targetItr = 1:numel(targetSelector)
   
    select(targetSelector{targetItr}, data);
    
    firstLevelFeats(targetItr) = firstLevel(data, ...
        targetSelector{targetItr});
    
    restore_selection(data);
    
end

featVals = secondLevel(firstLevelFeats, targetSelector);


% Write features to log file
if verbose,
    fprintf([verboseLabel 'Writing event features to features.txt ...']);
end
fid = get_log(obj, 'features.txt');
hdr = repmat('%s,',1, numel(featNames));
fprintf(fid, [hdr '\n'], featNames{:});
fmt = repmat('%10.4f,', 1, numel(featNames));
fprintf(fid, fmt, featVals);

print_paragraph(rep, 'Extracted features: [features.txt][feat]');
print_link(rep, '../features.txt', 'feat');
if verbose, fprintf('\n\n'); end


end