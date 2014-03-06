function id = version()

import mperl.file.spec.rel2abs;
import safefid.safefid;

FILE_NAME = '.git/refs/heads/master';

dirName = rel2abs([meegpipe.root_path filesep '..']);

currDir = pwd;
try
    cd(dirName);
    if exist(FILE_NAME, 'file')
        fid = safefid.fopen(FILE_NAME, 'r');
        id = fid.fgetl;
    else
        % If the user followed the installation instructions on the web,
        % then his meegpipe installation dir is named
        % meegpipe/meegpipe-meegpipe-[version]
        dirName = rel2abs('.');
        match = regexp(dirName, 'meegpipe-meegpipe-(?<id>\w+)$', 'names');
        if isempty(match)
            warning('meegpipe:version:Unknown', ...
                ['Could not figure out meegpipe version. You may have ' ... 
                'problems reproducing your results in the future. ' ...
                'To solve this issue, follow exactly the installation ' ...
                'instructions at http://germangh.com/meegpipe']);
            id = 'unknown';
        else
            id = match.id;
        end        
    end
catch ME
    cd(currDir);
    rethrow(ME);
end
cd(currDir);


end