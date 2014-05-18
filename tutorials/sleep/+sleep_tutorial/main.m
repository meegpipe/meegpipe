% MAIN

import mperl.file.spec.catdir;
import mperl.file.spec.catfile;

files =  mperl.file.find.finddepth_regex_match('140517-220216', '.*108.*1_mff2pset.pset.*');
files = somsds.link2files(files, catdir(pwd, 'recordings'));

files = misc.dir(catdir(pwd, 'recordings'), '.pseth$');
files = catfile(catdir(pwd, 'recordings'), files);

myPipe = sleep_tutorial.splitting_pipeline('OGE', false);
run(myPipe, files{:});