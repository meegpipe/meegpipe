function preprocess
% PREPROCESS - Preprocess TMSi data files
%
% 

import mperl.file.spec.catdir;
import mperl.file.find.finddepth_regex_match;

INPUT_DIR = pwd;
OUTPUT_DIR = catdir(pwd, 'tmsi_eeg_tutorial');

PARALELLIZE = true; % Should each file be processed in parallel?
DO_REPORT   = true; % Should full HTML reports be generated?

myPipe = tmsi_eeg.basic_pipeline(...
    'GenerateReport', DO_REPORT, ...
    'Parallelize',    PARALELLIZE);

regex = '.Poly5$';
inputFiles = finddepth_regex_match(INPUT_DIR, regex, false);
somsds.link2files(inputFiles, OUTPUT_DIR);
links2Files = finddepth_regex_match(OUTPUT_DIR, regex);

run(myPipe, links2Files{:});

end
