function extract_pvt_features
% EXTRACT_PVT_FEATURES - Extract PVT features from BATMAN data

meegpipe.initialize;

% Import some utilities
import mperl.file.find.finddepth_regex_match;
import misc.get_username;

% The directory where the split data files are located
INPUT_DIR = [ ...
    '/data1/projects/meegpipe/batman_tut/' ...
    get_username ...
    '/split_files_output'];

% The output directory where we want to store the features
OUTPUT_DIR = [...
    '/data1/projects/meegpipe/batman_tut/' ...
    get_username ...
    '/extract_pvt_features_output'];

% Ensure the output directory exists (Unix-specific)
system(['mkdir -p ' OUTPUT_DIR])

% Some (optional) parameters that you may want to play with when experimenting
% with your processing pipeline
PARALLELIZE = true; % Should each file be processed in parallel?
DO_REPORT   = true; % Should full HTML reports be generated?

% Create an instance of the feature extraction pipeline
myPipe = batman.extract_pvt_features_pipeline(...
    'GenerateReport', DO_REPORT, ...
    'Parallelize',    PARALLELIZE);

% Note that we have not yet written function extract_pvt_feature_pipeline!

% Generate links to the relevant data files into the output directory. This
% step is equivalent to copying the relevant data files into the output
% directory but has the advantage of saving valuable disk space.
regex = 'split_files-.+_\d+\.pseth?';
splittedFiles = finddepth_regex_match(INPUT_DIR, regex, false);
somsds.link2files(splittedFiles, OUTPUT_DIR);
% Note that we use a regex that will match only those files that contain
% PVT events. 
files = finddepth_regex_match(OUTPUT_DIR, regex);

% files should now be a cell array containing the full paths to the single
% sub-block .pseth files that were generated in the data splitting stage.
run(myPipe, files{:});

end