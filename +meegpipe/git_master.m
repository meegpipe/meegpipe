function y = git_master
% GIT_MASTER - Returns hash of GIT master head snapshot

import meegpipe.root_path;

fileName = fullfile(root_path, '..', '.git', 'refs', 'heads', 'master');

fid = fopen(fileName, 'r');
if fid < 1,
    error('I could not open %s for reading', fileName);
end
try
    y = fgetl(fid);
catch ME
    close(fid);
    rethrow(ME);
end

fclose(fid);


end