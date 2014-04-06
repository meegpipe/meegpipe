function data = stage2(varargin)
% STAGE2 - Artifact correction
%
% stage2('option1', val1, 'option2', val2, ...)
%
% Where 'optionX', valX, are optional parameters. See below for a list of
% the options that are recognized by this function. Any non-recognized
% option will be passed directly to the pipeline associated to stage1
% (ssmd_auob.artifact_correction_pipeline). 
%
% ## Accepted arguments (as key/value pairs):
%
% Subject              :   (numeric array) Defualt: 1:1000
%                          The IDs of the subjects to be processed
%
% Condition            :   (cell array) Default: {'arsq', 'baseline', 'pvt', 'rs'}
%                          List of experimental conditions to consider for
%                          processing/analysis.
%
% InputDir             :   (string) Default: misc.find_latest_dir('/data1/projects/ssmd-erp/analysis/stage1')
%                          The full path to the directory containing the
%                          results of stage1.
%
% OutputDir            :   (string) Default:  ['/data1/projects/ssmd-erp/analysis/stage2/' datestr(now, 'yymmdd-HHMMSS')]
%                          The full path to the directory where the results
%                          of this stage should be stored.
%
%
% ## Usage examples:
%
% % Run the analysis for all files but run the processing jobs at 
% %'long.q' instead of at the default OGE queue ('short.q'):
%
% stage2('Queue', 'long.q');
%
%
% See also: ssmd_auob.artifact_correction_pipeline, ssmd_auob.stage1


meegpipe.initialize;

import mperl.file.spec.*;
import mperl.file.find.*;
import somsds.link2files;
import mperl.join;
import misc.process_arguments;
import misc.split_arguments;
import misc.find_latest_dir;

% Subjects 151 and 152 are special because for those subjects we should not
% discard events that have missing responses
opt.Subject                 = 1:1000;
opt.Condition               = {'arsq', 'baseline', 'pvt', 'rs'};
opt.InputDir                = '';
opt.OutputDir               = ...
    ['/data1/projects/ssmd-erp/analysis/stage2/' datestr(now, 'yymmdd-HHMMSS')];

[thisArgs, varargin] = split_arguments(opt, varargin);
[~, opt] = process_arguments(opt, thisArgs);

if isempty(opt.InputDir),
    opt.InputDir = find_latest_dir(...
        '/data1/projects/ssmd-erp/analysis/stage1');
end

if isempty(opt.InputDir) || ~exist(opt.InputDir, 'dir')
    error('You must specify a valid input directory!');
end

% First we create links to all relevant files in the OUTPUT_DIR
if numel(opt.Subject) > 1,
    subjRegex = join('|', opt.Subject);
else
    subjRegex = num2str(opt.Subject);
end

regex = ['_0+(' subjRegex ')_.+_stg1\.pseth?$'];
myFiles = finddepth_regex_match(opt.InputDir, regex);
myFiles = link2files(myFiles, opt.OutputDir);

if isempty(myFiles),
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

if numel(myFiles) > 1,
    fprintf('\n\nGoing to process %d file(s):\n', ...
        numel(myFiles));
    fprintf('%s\n', myFiles{1});
    
    fprintf('...\n');
    fprintf('%s\n\n', myFiles{end});
end

fprintf('\nPress CTRL+C to cancel or any other key to proceed ...\n');
pause;

%% Run the pipeline
myPipe = ssmd_auob.artifact_correction_pipeline(...
    'Name',                 'stg2', ...
    varargin{:});

data = run(myPipe, myFiles{:});


end