function dirName = get_tempdir(obj)

import mperl.file.spec.catdir;

if ~isempty(get_parent(obj)),
    
    dirName = get_tempdir(get_parent(obj));
    
else
    
    dirName = catdir(get_full_dir(obj), 'tmp');
    
end


end