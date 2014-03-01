function cleaning(varargin)
% CLEANING - Clean all BATMAN EEG files

% Import some utilities
import mperl.file.find.finddepth_regex_match;
import misc.process_arguments;
import misc.split_arguments;

opt.Date     = datestr(now, 'yymmdd_HHMMSS');
opt.Subjects = 1:10; 
opt.Conditions = {'arsq', 'baseline', 'pvt', 'rs'};
[thisArgs, varargin] = split_arguments(opt, varargin);
[~, opt] = process_arguments(opt, thisArgs, [], true);

% Just in case you forgot to do it when you started MATLAB
meegpipe.initialize;

% The directory where the cleaning results should be stored
OUTPUT_DIR = ...
    ['/data1/projects/batman/analysis/cleaning/' ...
    opt.Date];


% Ensure the directory exists (Unix-specific)
system(['mkdir -p ' OUTPUT_DIR]);

% Some (optional) parameters that you may want to play with when experimenting
% with your processing pipeline
PARALELLIZE = true; % Should each file be processed in parallel?
DO_REPORT   = true; % Should full HTML reports be generated?

% Create an instance of the feature extraction pipeline
myPipe = batman_eeg.cleaning_pipeline(...
    'GenerateReport', DO_REPORT, ...
    'Parallelize',    PARALELLIZE, ...
    varargin{:});

somsds.link2rec(...
    'batman',       ...                  % The recording ID
    'subject',      opt.Subjects, ...    % The subject ID(s)
    'modality',     'eeg', ...           % The data modality
    'condition',    opt.Conditions, ...
    'file_regex',   '\.pset', ...     % Only pset/pseth files
    'folder',       OUTPUT_DIR);

regex = '\.pseth$';
files = finddepth_regex_match(OUTPUT_DIR, regex);

% files should now be a cell array containing the full paths to the single
% sub-block .pseth files that were generated in the data splitting stage.

run(myPipe, files{:});

end