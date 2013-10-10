function chanSetName = get_channel_set_name(chanSet)

import mperl.join;

if numel(chanSet) > 2 && strcmp(chanSet(1), '^') && ...
        strcmp(chanSet(end), '$'),
    chanSetName = chanSet(2:end-1);
else
    chanSetName = chanSet;
end

chanSetName = regexprep(chanSetName, '\s+', '_');

end