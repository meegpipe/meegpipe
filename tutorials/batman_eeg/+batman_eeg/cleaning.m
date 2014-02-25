function cleaning(varargin)
% CLEANING - Clean all BATMAN EEG files

% Just in case you forgot to do it when you started MATLAB
meegpipe.initialize;

% Import some utilities
import mperl.file.find.finddepth_regex_match;

% The directory where the cleaning results should be stored
OUTPUT_DIR = ...
    ['/data1/projects/batman/analysis/cleaning/' ...
    datestr(now, 'yymmdd_HHMMSS')];


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
    'subject',      1:10, ...            % The subject ID(s)
    'modality',     'eeg', ...           % The data modality
    'file_regex',   '\.pset', ...     % Only pset/pseth files
    'folder',       OUTPUT_DIR);

regex = '\.pseth$';
files = finddepth_regex_match(OUTPUT_DIR, regex);

% files should now be a cell array containing the full paths to the single
% sub-block .pseth files that were generated in the data splitting stage.

run(myPipe, files{:});

end