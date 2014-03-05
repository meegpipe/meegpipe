function id = version()

import mperl.file.spec.rel2abs;
import safefid.safefid;

dirName = rel2abs([meegpipe.root_path filesep '..']);

currDir = pwd;
try
    cd(dirName);
    fid = safefid.fopen('.git/refs/heads/master', 'r');
    id = fid.fgetl;

catch ME
    cd(currDir);
    rethrow(ME);
end
cd(currDir);


end