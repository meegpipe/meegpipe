function split_files
% SPLIT_FILES - Split grungerb recordings into multiple epochs

meegpipe.initialize;

import mperl.file.find.finddepth_regex_match;
import misc.get_username;
import mperl.file.spec.catdir;
import misc.get_hostname;

if ispc && strcmp(get_hostname, 'NIN271'),
    ROOT_PATH = 'D:/';
else
    ROOT_PATH = pwd;
end

PREPROC_DATE = '1402191116';
INPUT_DIR = catdir(ROOT_PATH, 'tmsi_eeg_tutorial', 'preprocess', PREPROC_DATE);
OUTPUT_DIR = catdir(ROOT_PATH, 'tmsi_eeg_tutorial', 'split_files', ...
    datestr(now, 'yymmddHHMM'));

PARALELLIZE = true; % Should each file be split in parallel?
DO_REPORT   = true; % Should full HTML reports be generated?

% Create an instance of the feature extraction pipeline
myPipe = tmsi_eeg.split_files_pipeline(...
    'GenerateReport', DO_REPORT, ...
    'Parallelize',    PARALELLIZE);

regex = 'preprocess-pipeline\.pset';
splittedFiles = finddepth_regex_match(INPUT_DIR, regex, false);
somsds.link2files(splittedFiles, OUTPUT_DIR);
regex = '\.pseth$';
files = finddepth_regex_match(OUTPUT_DIR, regex);

run(myPipe, files{:});

end