function [data, dataNew] = process(obj, data, varargin)

import misc.isinteger;

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

firstLevelFeats = cell(numel(firstLevel), numel(targetSelector));

selectionEvents = cell(1, numel(targetSelector));

for targetItr = 1:numel(targetSelector)
    
    % selectionEvents is only relevant for event_selector selectors
    [~, selectionEvents{targetItr}] = ...
        select(targetSelector{targetItr}, data);
    
    for featItr = 1:numel(firstLevel)
        firstLevelFeats{featItr, targetItr} = firstLevel{featItr}(data, ...
            selectionEvents{targetItr}, targetSelector{targetItr});
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
    % selector_hash,selector_idx, feat1, feat2, ...
    % X, Y, Z
    % ....
    % In this case, featNames is assumed to refer to first-level features, 
    % which are assumed to be numeric, for simplicity
    hdr = ['selector_hash,selector_idx,', ...
        repmat('%s,',1, numel(featNames))];
    hdr(end:end+1) = '\n';
    fprintf(fid, hdr, featNames{:});
    fmt = '%s, %d,'; 
    
    for i = 1:numel(featNames),
       if ischar(firstLevelFeats{1, i}),
           fmt = [fmt '%s,'];
       elseif isinteger(firstLevelFeats{1, i})
           fmt = [fmt '%s,'];
       elseif isnumeric(firstLevelFeats{1, i}),
           fmt = [fmt '%.4f,'];
       else
          error('Feature values must be numeric scalars or strings'); 
       end
        
    end
 
    fmt(end:end+1) = '\n';
    for i = 1:numel(targetSelector)
        fprintf(fid, fmt, ...
            get_hash_code(targetSelector{i}), i, firstLevelFeats{:, i});
    end    
    
else
    % Aggregate features across selectors
    % Write:
    % feat1, feat2
    % X, Y
    
    featVals = cell(1, numel(secondLevel));
    
    for i = 1:numel(featVals),
        featVals{i} = secondLevel{i}(firstLevelFeats, ...
            selectionEvents, targetSelector);
    end
    hdr = repmat('%s,',1, numel(featNames));
    hdr(end) = [];    
    fprintf(fid, [hdr '\n'], featNames{:});
    
    fmt = '';
    for i = 1:numel(featVals),
        if isinteger(featVals{i}),
            fmt = [fmt '%d,'];
        elseif isnumeric(featVals{i}),
            fmt = [fmt '%.4f,'];
        elseif ischar(featVals{i}),
            fmt = [fmt '%s,'];
        else
            error('Features must be numeric scalars or strings');
        end
    end
    fmt(end:end+1) = '\n';
    fprintf(fid, fmt, featVals{:});
    
end

rep = get_report(obj);
print_paragraph(rep, 'Extracted features: [features.txt][feat]');
print_link(rep, '../features.txt', 'feat');
if verbose, fprintf('\n\n'); end


end