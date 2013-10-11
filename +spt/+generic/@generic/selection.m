function idx = selection(obj)

import spt.generic.generic;

if isempty(obj.W),
    throw(abstract_spt.NeedsLearning);
end

idx = find(obj.Selected);

end