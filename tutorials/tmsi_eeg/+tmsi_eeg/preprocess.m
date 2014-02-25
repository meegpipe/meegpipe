function preprocess
% PREPROCESS - Clean files and prepare them for spectral analysis
%
%
% 

meegpipe.initialize;

import mperl.file.spec.catdir;
import misc.dir;
import misc.get_hostname;


ROOT_PATH = '/data1/projects/grunberg/analysis';

INPUT_DIR = '/data1/projects/grunberg/recordings';
OUTPUT_DIR = catdir(ROOT_PATH, 'preprocess', ...
    datestr(now, 'yymmddHHMM'));

% Should each file be processed in parallel? Set this to false to ensure
% that files will be processed sequentially within the current MATLAB
% session (good for debugging purposes, as all status messages will be
% displayed on the current MATLAB session's command window). 
PARALELLIZE = true; 

% Should full HTML reports be generated?
DO_REPORT   = true; 

myPipe = tmsi_eeg.preprocess_pipeline(...
    'GenerateReport', DO_REPORT, ...
    'Parallelize',    PARALELLIZE);

regex = '.Poly5$';
inputFiles = dir(INPUT_DIR, regex, true, false, true);
somsds.link2files(inputFiles, OUTPUT_DIR);
links2Files = dir(OUTPUT_DIR, regex, true, false, true);

run(myPipe, links2Files{:});

end
