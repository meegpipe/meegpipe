function disp_body(obj)

import misc.dimtype_str;
import mperl.join;

disp_body@goo.abstract_configurable(obj);

filtObj  = get_config(obj, 'Filter');
embedDim = get_config(obj, 'EmbedDim');
dataSel  = get_config(obj, 'DataSelector');

doLink = usejava('Desktop');

fprintf('%20s : %s\n',  'Name',           get_name(obj));

if ~isempty(filtObj),
    fprintf('%20s : [%s]\n',  'Filter', dimtype_str(filtObj, doLink));
end

if ~isempty(dataSel),
    fprintf('%20s : [%s]\n',  'DataSelector', ...
        dimtype_str(dataSel, doLink));
end

fprintf('%20s : %d\n',  'EmbedDim',       embedDim);

fprintf('%20s : %d\n',  'NbComp',         obj.NbComp);

if ~isempty(obj.Selected),
    fprintf('%20s : %s\n',  'Selected',   join(', ', find(obj.Selected)));
end

fprintf('%20s : %d\n',  'DimIn',          obj.DimIn);

fprintf('%20s : %d\n',  'DimOut',         obj.DimOut);


end

