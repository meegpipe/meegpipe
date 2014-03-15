function spectral_analysis(varargin)
% SPECTRAL_ANALYSIS - Perform spectral analysis on the clean dataset

import misc.find_latest_dir;
import misc.split_arguments;
import misc.process_arguments;
import  mperl.file.find.finddepth_regex_match;

% Just in case you forgot to do it when you started MATLAB
meegpipe.initialize;

opt.Date     = datestr(now, 'yymmdd_HHMMSS');
opt.Subject  = 1:10; 
opt.Condition = {'arsq', 'baseline', 'pvt', 'rs'};
opt.OutputDir = '';
opt.InputDir  = '';

[thisArgs, varargin] = split_arguments(opt, varargin);
[~, opt] = process_arguments(opt, thisArgs, [], true);

if isempty(opt.OutputDir),
    opt.OutputDir = ['/data1/projects/batman/analysis/spectral_analysis/'  opt.Date];
end

if isempty(opt.InputDir),
    opt.InputDir = find_latest_dir(...
       '/data1/projects/batman/analysis/cleaning');
end

if isempty(opt.InputDir) || ~exist(opt.InputDir, 'dir')
    error('You must specify a valid input directory!');
end

% First we create links to all relevant files in the output dir
subjRegex = arrayfun(@(x) sprintf('%0.4d', x), opt.Subject, ...
    'UniformOutput', false);
subjRegex = ['(' mperl.join('|', subjRegex) ')'];
condRegex = ['(' mperl.join('|', opt.Condition) ')'];
regex = ['batman_' subjRegex '_eeg_' condRegex ...
    '_.+cleaning_pipe-ad49a8_.+cleaning-pipe\.pset'];
cleanedFiles = finddepth_regex_match(opt.InputDir, regex, false);
somsds.link2files(cleanedFiles, opt.OutputDir);
regex = '\.pseth$';
files = finddepth_regex_match(opt.OutputDir, regex);

if isempty(files),
    fprintf('No input files were found: nothing done\n\n');
    return;
end

fprintf('ANALYSIS PARAMETERS:\n');
fprintf('--------------------\n\n');
fNames = fieldnames(opt);
for i = 1:numel(fNames),
   fprintf('%20s : %s\n', fNames{i}, misc.any2str(opt.(fNames{i}), 100)); 
end
fprintf('\nPress CTRL+C to cancel or any other key to proceed ...\n');
pause;

fprintf('\n\nGoing to process %d file(s):\n', numel(files));
fprintf('%s\n', files{1});
if numel(files) > 1,
    fprintf('...\n');
    fprintf('%s\n\n', files{end});
end
fprintf('\nPress CTRL+C to cancel or any other key to proceed ...\n');
pause;

myPipe = batman_eeg.spectral_analysis_pipeline(varargin{:});

run(myPipe, files{:});

end