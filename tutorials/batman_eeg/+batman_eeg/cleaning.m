function cleaning(varargin)
% CLEANING - Clean all BATMAN EEG files

% Import some utilities
import mperl.file.find.finddepth_regex_match;
import misc.process_arguments;
import misc.split_arguments;

opt.Test     = false;
opt.Date     = datestr(now, 'yymmdd_HHMMSS');
opt.Subjects = 1:10; 
opt.Conditions = {'arsq', 'baseline', 'pvt', 'rs'};
[thisArgs, varargin] = split_arguments(opt, varargin);
[~, opt] = process_arguments(opt, thisArgs, [], true);

% Just in case you forgot to do it when you started MATLAB
meegpipe.initialize;

% The directory where the cleaning results should be stored
if opt.Test,
   ROOT_DIR = '/data1/projects/batman/analysis/cleaning/tests_IGNORE_THIS/';  
else
   ROOT_DIR = '/data1/projects/batman/analysis/cleaning/'; 
end
OUTPUT_DIR = [ROOT_DIR opt.Date];

% Ensure the directory exists (Unix-specific)
system(['mkdir -p ' OUTPUT_DIR]);

PARALELLIZE = true; % Should each file be processed in parallel?
DO_REPORT   = true; % Should full HTML reports be generated?


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

regex = 'rs_\d+\.pseth$';
files = finddepth_regex_match(OUTPUT_DIR, regex);

run(myPipe, files{:});

end