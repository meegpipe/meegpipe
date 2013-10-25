function bool = has_hrv

import mperl.file.spec.catfile;

if isunix,
    [~, res] = system('get_hrv');
else
    cygbin = val(meegpipe.get_config, 'cygwin', 'bindir');
    
    run = catfile(cygbin, 'run');
    
    [~, res] = system('
    


end