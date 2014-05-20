function fid = get_fid(obj)

import mperl.file.spec.catfile;
import safefid.safefid;

fid = obj.FID;

if isa(fid, 'safefid.safefid') && ~fid.Valid,
    fileName = catfile(obj.RootPath, obj.FileName);
    % A quick and dirty fix. This should never happen, but it does due to a
    % bug hidden somewhere
    obj.FID = [];
    fid     = []; %#ok<NASGU>
    fid = safefid.fopen(fileName, 'a+');
    obj.FID = fid;    
end

end