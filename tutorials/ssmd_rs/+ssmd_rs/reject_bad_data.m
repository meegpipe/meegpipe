function reject_bad_data
% REJECT_BAD_DATA - Reject bad data samples and bad data channels

meegpipe.initialize;

% Import some utilities
import mperl.file.find.finddepth_regex_match;
import misc.get_hostname;
import misc.get_username;
import mperl.file.spec.catdir;

switch lower(get_hostname),
    case {'somerenserver', 'nin389'},
        % The directory where the split data files are located
        INPUT_DIR = catdir('/data1/projects/meegpipe/ssmd_rs_tut/', ...
            get_username, 'remove_trends_output');
        % The output directory where we want to store the features
        OUTPUT_DIR = catdir('/data1/projects/meegpipe/ssmd_rs_tut/', ...
            get_username, 'reject_bad_data_output');        
    otherwise
        INPUT_DIR  = '/Volumes/DATA/tutorial/ssmd_rs/remove_trends_output';
        OUTPUT_DIR = '/Volumes/DATA/tutorial/ssmd_rs/reject_bad_data_output';
end

% Some (optional) parameters that you may want to play with when experimenting
% with your processing pipeline
PARALELLIZE = true; % Should each file be processed in parallel?
DO_REPORT   = true; % Should full HTML reports be generated?

% Create an instance of the bad data rejection pipeline
myPipe = ssmd_rs.reject_bad_data_pipeline(...
    'GenerateReport', DO_REPORT, ...
    'Parallelize',    PARALELLIZE);

% Note that we have not yet written function extract_abp_feature_pipeline!

% Generate links to the relevant data files into the output directory. This
% step is equivalent to copying the relevant data files into the output
% directory but has the advantage of saving valuable disk space.
regex = 'hpfilt_pipeline-.+\.pseth?';
inputFiles = finddepth_regex_match(INPUT_DIR, regex, false, true);
if isempty(inputFiles),
    error('No files match pattern %s under directory %s', ...
        regex, INPUT_DIR);
end
somsds.link2files(inputFiles, OUTPUT_DIR);
regex = '\.pseth$';
files = finddepth_regex_match(OUTPUT_DIR, regex);

% files should now be a cell array containing the full paths to the single
% sub-block .pseth files that were generated in the data splitting stage.

run(myPipe, files{:});

end