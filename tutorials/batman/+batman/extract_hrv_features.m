function extract_hrv_features
% EXTRACT_HRV_FEATURES - Extract HRV features from BATMAN data

% Just in case you forgot to do it when you started MATLAB
meegpipe.initialize;

% Import some utilities
import mperl.file.find.finddepth_regex_match;
import misc.get_username;

% The input directory (the output directory of the splitting stage)
INPUT_DIR = [ ...
    '/data1/projects/meegpipe/batman_tut/' ...
    get_username ...
    '/split_files_output'];

% The output directory where we want to store the features
OUTPUT_DIR = [...
    '/data1/projects/meegpipe/batman_tut/' ...
    get_username ...
    '/extract_hrv_features_output'];

% Ensure that the output directory exists (Unix-specific)
system(['mkdir -p ' OUTPUT_DIR]);

% Some (optional) parameters that you may want to play with when experimenting
% with your processing pipeline
PARALLELIZE = true; % Should each file be processed in parallel?
DO_REPORT   = true; % Should full HTML reports be generated?

% Create an instance of the feature extraction pipeline
myPipe = batman.extract_hrv_features_pipeline(...
    'GenerateReport', DO_REPORT, ...
    'Parallelize',    PARALLELIZE);

% Generate links to the relevant data files into the output directory. This
% step is equivalent to copying the relevant data files into the output
% directory but has the advantage of saving valuable disk space.
regex = 'split_files-.+_\d+\.pseth?';
splittedFiles = finddepth_regex_match(INPUT_DIR, regex, false);
somsds.link2files(splittedFiles, OUTPUT_DIR);
regex = '\.pseth$';
files = finddepth_regex_match(OUTPUT_DIR, regex);

% files should now be a cell array containing the full paths to the single
% sub-block .pseth files that were generated in the data splitting stage.
run(myPipe, files{:});

end