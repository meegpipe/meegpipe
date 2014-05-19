function fid = get_fid(obj)

import mperl.file.spec.catfile;
import safefid.safefid;

MAX_TRIES = 10;

fid = obj.FID;

if isa(fid, 'safefid.safefid') && ~fid.Valid,
    fileName = catfile(obj.RootPath, obj.FileName);
    % A quick and dirty fix. This should never happen, but it does due to a
    % bug hidden somewhere
    obj.FID = safefid.fopen(fileName, 'a+');
    fid = obj.FID;
    % No idea why, but sometimes it does not work...
    if ~fid.Valid,
        count = 0;
        while count < MAX_TRIES && ~fid.Valid
            tmpFid = fopen(fileName, 'a+');
            fprintf(tmpFid, '\n');
            fclose(tmpFid);
            pause(1);

            obj.FID = safefid.fopen(fileName, 'a+');
            count = count + 1;
            fid = obj.FID;
        end
    end
    if ~fid.Valid,
        error('Could not open report file for writing');
    end
end

end