function [data, dataNew] = process(obj, data, varargin)

import misc.eta;
import misc.epoch_get;
import meegpipe.node.erp.compute_erp_features;
import meegpipe.node.erp.generate_erp_images;
import meegpipe.node.erp.generate_erp_topos;
import report.generic.generic;
import misc.any2str;

dataNew = [];

verboseLabel = get_verbose_label(obj);
verbose = is_verbose(obj);


% Configuration options
evSel           = get_config(obj, 'EventSelector');
featList        = get_config(obj, 'Features');
feat2String     = get_config(obj, 'Feature2String');

if ischar(featList), featList = {featList}; end

ev = get_event(data);

numEvents = numel(ev);
if verbose,
    fprintf([verboseLabel 'Dataset contains %d events...\n\n'], numEvents);
end

if ~isempty(ev),
    ev = select(evSel, ev);
    if verbose,
        fprintf([verboseLabel 'Selected %d/%d events...\n\n'], ...
            numel(ev), numEvents);
    end
end

if isempty(ev),
    warning('ev_features:NoEvents', ...
        'No events were selected so no features were extracted');
    return;
end

% Write all event properties to log file
evLogName = [get_name(data) '_events.log'];
fid = get_log(obj, evLogName);
fprintf(fid, ev);

rep = get_report(obj);
print_title(rep, 'Data processing report', get_level(rep) + 1);

print_paragraph(rep, 'Selected events: [%s][evlog]', ...
    evLogName);
print_link(rep, ['../' evLogName], 'evlog');

% Write features
if verbose,
    fprintf([verboseLabel 'Writing event features to features.txt ...']);
end
fid = get_log(obj, 'features.txt');
hdr = repmat('%s,',1, numel(featList));
fprintf(fid, [hdr '\n'], featList{:});
specialFeat = keys(feat2String);
[specialFeat, iSpecial] = intersect(featList, specialFeat);
[stdFeat, iStd]         = setdiff(featList, specialFeat);

defValues = repmat({''}, 1, numel(featList));
fmt = repmat('%s,', 1, numel(featList));
fmt(end:end+1) = '\n';
evProps = fieldnames(ev(1));
if verbose,
    iBy100 = max(1, floor(numel(ev)/100));
    tinit  = tic;
end
for i = 1:numel(ev)
    values = defValues;
    for j = 1:numel(stdFeat)
        if ismember(stdFeat{j}, evProps),
            thisValue = get(ev(i), stdFeat{j});
        else
            thisValue = get_meta(ev(i), stdFeat{j});
        end
        values{iStd(j)} = any2str(thisValue, 100);
    end
    for j = 1:numel(specialFeat)
        if ismember(specialFeat{j}, evProps),
            thisValue = get(ev(i), specialFeat{j});
        else
            thisValue = get_meta(ev(i), specialFeat{j});
        end
        % Convenient, but ugly and slow...
        if isempty(thisValue) && strcmp(specialFeat{j}, 'Time'),
            [~, thisValue] = get_sampling_time(data, get_sample(ev(i)));
        end
        fh = feat2String(specialFeat{j});
        values{iSpecial(j)} = fh(thisValue);
    end
    fprintf(fid, fmt, values{:});
    if verbose && ~mod(i, iBy100),
        eta(tinit, numel(ev), i);
    end
end
print_paragraph(rep, 'Event features: [features.txt][feat]');
print_link(rep, '../features.txt', 'feat');
if verbose, fprintf('\n\n'); end


end