function preprocess(varargin)
% PREPROCESS - Clean files and prepare them for spectral analysis
%
%
% 

meegpipe.initialize;

import mperl.file.spec.catdir;
import misc.dir;
import misc.get_hostname;


if ~isempty(regexp(get_hostname, 'outolintu', 'once')),
    ROOT_PATH = '/Volumes/DATA/tutorial/grunberg';
    INPUT_DIR = '~/Dropbox/somerenserver';
else
    INPUT_DIR = '/data1/projects/grunberg/recordings';
    ROOT_PATH = '/data1/projects/grunberg/analysis';
end


OUTPUT_DIR = catdir(ROOT_PATH, 'preprocess', ...
    datestr(now, 'yymmdd-HHMMSS'));

% Should each file be processed in parallel? Set this to false to ensure
% that files will be processed sequentially within the current MATLAB
% session (good for debugging purposes, as all status messages will be
% displayed on the current MATLAB session's command window). 
PARALELLIZE = true; 

% Should full HTML reports be generated?
DO_REPORT   = true; 

myPipe = grunberg.preprocess_pipeline(...
    'GenerateReport', DO_REPORT, ...
    'Parallelize',    PARALELLIZE, ...
    varargin{:});

regex = '.Poly5$';
inputFiles = dir(INPUT_DIR, regex, true, false, true);
somsds.link2files(inputFiles, OUTPUT_DIR);
links2Files = dir(OUTPUT_DIR, regex, true, false, true);

run(myPipe, links2Files{:});

end
