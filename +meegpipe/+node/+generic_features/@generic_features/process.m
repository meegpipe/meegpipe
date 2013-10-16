function [data, dataNew] = process(obj, data, varargin)


dataNew = [];

verboseLabel = get_verbose_label(obj);
verbose = is_verbose(obj);


% Configuration options
targetSelector  = get_config(obj, 'TargetSelector');
firstLevel      = get_config(obj, 'FirstLevel');
secondLevel     = get_config(obj, 'SecondLevel');
featNames       = get_config(obj, 'FeatureNames');

if isempty(firstLevel),
    warning('generic_features:NoFeatures', ...
        'No description available for first level features: doing nothing');
    rep = get_report(obj);
    print_paragraph(rep, ...
        'This node did nothing because property FirstLevel is empty');
    return;
end

firstLevelFeats = nan(numel(firstLevel), numel(targetSelector));
for targetItr = 1:numel(targetSelector)
    
    select(targetSelector{targetItr}, data);
    
    for featItr = 1:numel(firstLevel)
        firstLevelFeats(featItr, targetItr) = firstLevel{featItr}(data, ...
            targetSelector{targetItr});
    end
    
    restore_selection(data);
    
end


% Write features to log file
if verbose,
    fprintf([verboseLabel 'Writing event features to features.txt ...']);
end
fid = get_log(obj, 'features.txt');
if isempty(secondLevel),
    
    % Write:
    % selector, feat1, feat2, ...
    % X, Y, Z
    % ....
    % In this case, featNames is assumed to refer to first-level features
    hdr = ['%s,', repmat('%s,',1, numel(featNames))];hdr(end) = [];
    fprintf(fid, [hdr '\n'], featNames{:});
    fmt = ['selector,', repmat('%10.4f,', 1, numel(featNames))];
    fmt(end) = [];
    for i = 1:numel(targetSelector)
        fprintf(fid, fmt, firstLevelFeats);
    end    
    
else
    % Aggregate features across selectors
    % Write:
    % feat1, feat2
    % X, Y
    
    featVals = nan(1, numel(secondLevel));
    
    for i = 1:numel(featVals),
        featVals(i) = secondLevel{i}(firstLevelFeats, targetSelector);
    end
    hdr = repmat('%s,',1, numel(featNames));
    hdr(end) = [];    
    fprintf(fid, [hdr '\n'], featNames{:});
    fmt = repmat('%10.4f,', 1, numel(featNames)); 
    fmt(end) = [];
    fprintf(fid, fmt, featVals);
    
end

rep = get_report(obj);
print_paragraph(rep, 'Extracted features: [features.txt][feat]');
print_link(rep, '../features.txt', 'feat');
if verbose, fprintf('\n\n'); end


end