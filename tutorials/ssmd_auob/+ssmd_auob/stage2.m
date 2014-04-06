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
% IncludeMissingResp   :   (numeric array) Default: [151 152]
%                          An array of subjects IDs for which events with
%                          missing responses should be included in the
%                          analysis. 
%
% DiscardMissingResp   :   (numeric array) Default: setdiff(1:1000, IncludeMissingResp)
%                          An array of subject IDs for which events with
%                          missing responses should be discarded (the
%                          normal case).
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
% % Run the analysis for all subjects but do not discard missing responses
% % subjects 151 and 152. Also, run the processing jobs at 'long.q' instead
% % of at the default OGE queue ('short.q'):
%
% stage2('IncludeMissingResp', [151 152], 'Queue', 'long.q');
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
opt.DiscardMissingResp = [];
opt.IncludeMissingResp = [151 152];
opt.Condition               = {'arsq', 'baseline', 'pvt', 'rs'};
opt.InputDir                = '';
opt.OutputDir               = ...
    ['/data1/projects/ssmd-erp/analysis/stage2/' datestr(now, 'yymmdd-HHMMSS')];

[thisArgs, varargin] = split_arguments(opt, varargin);
[~, opt] = process_arguments(opt, thisArgs);

if isempty(opt.DiscardMissingResp),
    opt.DiscardMissingResp = setdiff(1:1000, opt.IncludeMissingResp);
end

if isempty(opt.InputDir),
    opt.InputDir = find_latest_dir(...
        '/data1/projects/ssmd-erp/analysis/stage1');
end

if isempty(opt.InputDir) || ~exist(opt.InputDir, 'dir')
    error('You must specify a valid input directory!');
end

% First we create links to all relevant files in the OUTPUT_DIR
if ~isempty(opt.DiscardMissingResp),
    if numel(opt.DiscardMissingResp) > 1,
        subjRegex = join('|', opt.DiscardMissingResp);
    else
        subjRegex = num2str(opt.DiscardMissingResp);
    end
    
    regex = ['_0+(' subjRegex ')_.+_stg1\.pseth?$'];
    myFilesDiscardMR = finddepth_regex_match(opt.InputDir, regex);
    myFilesDiscardMR = link2files(myFilesDiscardMR, opt.OutputDir);
else
    myFilesDiscardMR = {};
end

if ~isempty(opt.IncludeMissingResp),
    if numel(opt.IncludeMissingResp) > 1,
        subjRegex = join('|', opt.IncludeMissingResp);
    else
        subjRegex = num2str(opt.Subject);
    end
    
    regex = ['_0+(' subjRegex ')_.+_stg1\.pseth?$'];
    myFilesIncludeMR = finddepth_regex_match(opt.InputDir, regex);
    myFilesIncludeMR = link2files(myFilesIncludeMR, opt.OutputDir);
else
    myFilesIncludeMR = {};
end

if isempty(myFilesIncludeMR) && isempty(myFilesDiscardMR),
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

if numel(myFilesDiscardMR) > 1,
    fprintf('\n\nGoing to process %d file(s) discarding missing responses:\n', ...
        numel(myFilesDiscardMR));
    fprintf('%s\n', myFilesDiscardMR{1});
    
    fprintf('...\n');
    fprintf('%s\n\n', myFilesDiscardMR{end});
end

if numel(myFilesIncludeMR) > 1,
    fprintf('\n\nGoing to process %d file(s) including missing responses:\n', ...
        numel(myFilesIncludeMR));
    fprintf('%s\n', myFilesIncludeMR{1});
    
    fprintf('...\n');
    fprintf('%s\n\n', myFilesIncludeMR{end});
end

fprintf('\nPress CTRL+C to cancel or any other key to proceed ...\n');
pause;

%% Run the pipeline(s)
if numel(myFilesDiscardMR) > 1,
    myPipe1 = ssmd_auob.artifact_correction_pipeline(...
        'Name',                 'stg2', ...
        'DiscardMissingResp',   true, ...
        varargin{:});
    
    data = run(myPipe1, myFilesDiscardMR{:});
end

if numel(myFilesIncludeMR) > 1,
    myPipe1 = ssmd_auob.artifact_correction_pipeline(...
        'Name',                 'stg2', ...
        'DiscardMissingResp',   false, ...
        varargin{:});
    
    data = run(myPipe1, myFilesIncludeMR{:});
end

end