function didExtraction = extract_bss_features(obj, bssObj, ics, data, icSel)

import misc.num2strcell;
import misc.eta;

verboseLabel = get_verbose_label(obj);
verbose = is_verbose(obj);

featExtractor   = get_config(obj, 'Feature');
featTarget      = get_config(obj, 'FeatureTarget');

if isempty(featExtractor),
    didExtraction = false;
    return;
else
    didExtraction = true;
end

fid = get_log(obj, 'features.txt');
if verbose,
    fprintf([verboseLabel 'Writing BSS features to %s ...\n\n'], fid.FileName);
end

if strcmpi(featTarget, 'selected'),
    if isempty(icSel), return; end
    select(ics, icSel);
else
    clear_selection(bssObj);
end
        
icsHdr = arrayfun(@(i) ['BSS' num2str(i)], 1:size(ics,1), ...
    'UniformOutput', false);
hdr = ['feature_extractor,feature_name,', mperl.join(',', icsHdr) '\n'];

fid.fprintf(hdr);
for i = 1:numel(featExtractor)
    extractorName = get_name(featExtractor{i});
    if verbose,
        fprintf([verboseLabel 'Extracting feature %s ...\n\n'], ...
            get_name(featExtractor{i}));
    end
    [fVal, fName] = extract_feature(featExtractor{i}, bssObj, ics, data);
    if isempty(fName), fName = num2strcell(1:size(fVal, 1)); end
    fmt = repmat(',%.4f', 1, size(fVal, 2));
   
    if verbose,
        fprintf([verboseLabel, 'Writing feature %s ...'], ...
            get_name(featExtractor{i}));
        nIterBy100 = floor(size(fVal, 1)/100);
        tinit = tic;
    end
    
    for j = 1:size(fVal, 1)
        fid.fprintf('%s,%s', extractorName, fName{j});
        fid.fprintf([fmt '\n'], fVal(j,:));
        if verbose && ~mod(j, nIterBy100),
            misc.eta(tinit, size(fVal, 1), j);
        end
    end
    if verbose, 
        fprintf('\n\n');
        clear +misc/eta;
    end
end

if strcmpi(featTarget, 'selected'),
    restore_selection(ics);
end

if ics.Transposed,
    % The tstat feature extractor tranposes the ics physioset
    transpose(ics);
end

end