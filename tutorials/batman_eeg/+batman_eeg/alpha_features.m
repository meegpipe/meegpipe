function alpha_features(varargin)
% ALPHA_FEATURES - Extract alpha features from BATMAN files

% Import some utilities
import mperl.file.find.finddepth_regex_match;
import misc.process_arguments;
import misc.split_arguments;

opt.Test     = false;
opt.Date     = '';
opt.Subjects = 1:10; 
opt.Conditions = {'arsq', 'baseline', 'pvt', 'rs'};
[thisArgs, varargin] = split_arguments(opt, varargin);
[~, opt] = process_arguments(opt, thisArgs, [], true);

% Just in case you forgot to do it when you started MATLAB
meegpipe.initialize;

% The directory where the cleaning results are located
if ~isempty(opt.Date),
    INPUT_DIR = ['/data1/projects/batman/analysis/cleaning/' opt.Date]; 
else
   INPUT_DIR = misc.find_latest_dir('/data1/projects/batman/analysis/cleaning/');  
end

if opt.Test,
   OUTPUT_DIR = ['/data1/projects/batman/analysis/alpha_features/tests_IGNORE_THIS/' ...
       datestr(now, 'yymmdd_HHMM')];  
else
   OUTPUT_DIR = ['/data1/projects/batman/analysis/alpha_features/' ...
       datestr(now, 'yymmdd_HHMM')];  
end

fprintf('\nINPUT DIR: %s\n', INPUT_DIR);
fprintf('OUTPUT_DIR: %s\n\n', OUTPUT_DIR);

% Ensure the directory exists (Unix-specific)
system(['mkdir -p ' OUTPUT_DIR]);

% Some (optional) parameters that you may want to play with when experimenting
% with your processing pipeline
PARALELLIZE = true; % Should each file be processed in parallel?
DO_REPORT   = true; % Should full HTML reports be generated?

% Create an instance of the feature extraction pipeline
myPipe = batman_eeg.alpha_features_pipeline(...
    'GenerateReport', DO_REPORT, ...
    'Parallelize',    PARALELLIZE, ...
    varargin{:});

% Get the cleaned files and generate links to them in the output dir
subjRegex = arrayfun(@(x) sprintf('%0.4d', x), opt.Subjects, ...
    'UniformOutput', false);
subjRegex = ['(' mperl.join('|', subjRegex) ')'];
condRegex = ['(' mperl.join('|', opt.Conditions) ')'];
regex = ['batman_' subjRegex '_eeg_' condRegex ...
    '_.+cleaning_pipe-ad49a8_.+cleaning-pipe\.pset'];
cleanedFiles = finddepth_regex_match(INPUT_DIR, regex, false);
somsds.link2files(cleanedFiles, OUTPUT_DIR);
regex = '\.pseth$';
files = finddepth_regex_match(OUTPUT_DIR, regex);

fprintf('Number of input files: %d\n\n', numel(files));
fprintf('Input file #%d: %s', 1, files{1});
if numel(files) > 1,
    fprintf('Input file #%d: %s', numel(files), files{end});
end

run(myPipe, files{:});

end