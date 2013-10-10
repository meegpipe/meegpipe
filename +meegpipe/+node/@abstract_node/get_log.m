function fid = get_log(obj, filename)

import safefid.safefid;
import mperl.file.spec.catfile;

[~, name, ext] = fileparts(filename);

filename = catfile(get_full_dir(obj), [name ext]);

fidIdx = obj.LogMap_(filename);

if isempty(fidIdx),
    
    fid = safefid(filename, 'w');
    % And store it in the cache of FIDs
    obj.LogFID_{end+1}    = fid;
    fidIdx = numel(obj.LogFID_);
    obj.LogMap_(filename) = fidIdx;
    
else
    
    fid = obj.LogFID_{fidIdx};

end

end