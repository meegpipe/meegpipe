function disp_body(obj)

import mperl.join;

disp_body@spt.generic.generic(obj);

fprintf('%20s : %d\n',  'Samples',         obj.Samples);

if ~isempty(obj.CriterionValues),
    
    fprintf('%20s : %s\n',  'CriterionValues', ...
        join(', ', obj.CriterionValues));
    
end



end

