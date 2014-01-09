function remove_artifacts
% REMOVE_ARTIFACTS - Remove artifacts from SSMD resting state data

meegpipe.initialize;

% Import some utilities
import mperl.file.find.finddepth_regex_match;
import mperl.file.spec.catdir;
import misc.get_hostname;
import misc.get_username;

switch lower(get_hostname),
    case {'somerenserver', 'nin389'},
        % The directory where the split data files are located
        INPUT_DIR = catdir('/data1/projects/meegpipe/ssmd_rs_tut', ...
            get_username, 'reject_bad_data_output');
        % The output directory where we want to store the features
        OUTPUT_DIR = catdir('/data1/projects/meegpipe/ssmd_rs_tut', ...
            get_username, 'remove_artifacts_output');        
    otherwise
        INPUT_DIR = '/Volumes/DATA/tutorial/ssmd_rs/reject_bad_data_output';
        OUTPUT_DIR = '/Volumes/DATA/tutorial/ssmd_rs/remove_artifacts_output';
end

% Some (optional) parameters that you may want to play with when experimenting
% with your processing pipeline
PARALELLIZE = true; % Should each file be processed in parallel?
DO_REPORT   = true; % Should full HTML reports be generated?

% Create an instance of the feature extraction pipeline
myPipe = ssmd_rs.remove_artifacts_pipeline(...
    'GenerateReport', DO_REPORT, ...
    'Parallelize',    PARALELLIZE);

% Note that we have not yet written function remove_artifacts_pipeline!

% Generate links to the relevant data files into the output directory. This
% step is equivalent to copying the relevant data files into the output
% directory but has the advantage of saving valuable disk space.
regex = 'hpfilt-pipeline\.meegpipe.+bad-data\.pseth?';
inputFiles = finddepth_regex_match(INPUT_DIR, regex, false, true);
if isempty(inputFiles),
    error('No files match pattern %s under directory %s', ...
        regex, INPUT_DIR);
end
somsds.link2files(inputFiles, OUTPUT_DIR);
regex = '\.pseth$';
files = finddepth_regex_match(OUTPUT_DIR, regex);

% files should now be a cell array containing the full paths to the single
% sub-block .pseth files that were generated in the data splitting stage
run(myPipe, files{:});

end