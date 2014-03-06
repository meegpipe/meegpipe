function fid = get_fid(obj)

import mperl.file.spec.catfile;
import safefid.safefid;

fid = obj.FID;

if isa(fid, 'safefid.safefid') && ~fid.Valid,
    % A quick and dirty fix. This should never happen, but it does due to a
    % bug hidden somewhere
    obj.FID = safefid.fopen(catfile(obj.RootPath, obj.FileName), 'a+');
    fid = obj.FID;
end

end