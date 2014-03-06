function hs = get_hash_code(obj)

tmpHash = mjava.hash;

tmpHash('Config')       = get_hash_code(get_config(obj));
tmpHash('DataSelector') = struct(obj.DataSelector);

hs = get_hash_code(tmpHash);

end
