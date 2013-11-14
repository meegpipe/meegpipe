function hashCode = get_id(obj)
% GET_ID - Pipeline ID code (6 characters)


import datahash.DataHash;

hashCode1 = get_static_hash_code(obj);

% Get also a hash code for the version of meegpipe and its submods
hashCode2 = DataHash(meegpipe.version);

hashCode = DataHash({hashCode1, hashCode2});

hashCode = hashCode(end-5:end);

end