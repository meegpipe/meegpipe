function ref = get_ref(obj)

import datahash.DataHash;

title = get_title(obj);

if isempty(title),
    
    warning('off', 'JSimon:DataHash:BadDataType');
    ref = DataHash(struct(obj));
    warning('on', 'JSimon:DataHash:BadDataType');
    
elseif ~initialized(obj),
    
    initialize(obj);
    
    ref = get_ref(obj);
    
else
    
    ref = regexprep(title, '[^\w]+', '-');
    
end




end