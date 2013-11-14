function hashCode = cell2hashcode(cArray)

import datahash.DataHash;
import goo.pkgisa;
import goo.cell2hashcode;


for i = 1:numel(cArray),
    if pkgisa(cArray{i}, {'goo.hashable', 'goo.hashable_handle'}),
        cArray{i} = get_hash_code(cArray{i});
    elseif iscell(cArray{i}),
        cArray{i} = cell2hashcode(cArray{i});
    elseif isobject(cArray{i}),       
        cArray{i} = DataHash(struct(cArray{i}));
    else       
        cArray{i} = DataHash(cArray{i});
    end    
end

hashCode = DataHash(cArray);

end