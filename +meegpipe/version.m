function id = version()

import mperl.file.spec.rel2abs;

dirName = rel2abs([meegpipe.root_path filesep '..']);

currDir = pwd;
try
    cd(dirName);
    [~, id] = system('git rev-parse HEAD');
    id = regexprep(id, '[^\w]+$', '');
    
catch ME
    cd(currDir);
    rethrow(ME);
end
cd(currDir);


end