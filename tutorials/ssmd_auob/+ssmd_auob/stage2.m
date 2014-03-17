function data = stage2(varargin)

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
opt.SubjectDiscardMissingResp = setdiff(1:200, [151 152]);
opt.SubjectIncludeMissingResp = [151 152];
opt.Condition               = {'arsq', 'baseline', 'pvt', 'rs'};
opt.Queue                   = 'short.q';    
opt.InputDir                = '';
opt.OutputDir               = ...
    ['/data1/projects/ssmd-erp/analysis/stage2/' datestr(now, 'yymmdd-HHMMSS')];

[thisArgs, varargin] = split_arguments(opt, varargin);
[~, opt] = process_arguments(opt, thisArgs);

if isempty(opt.InputDir),
    % use the latest dir under /data1/projects/ssmd-erp/analysis/stage1
    opt.InputDir = find_latest_dir(...
        '/data1/projects/ssmd-erp/analysis/stage1');
end

if isempty(opt.InputDir) || ~exist(opt.InputDir, 'dir')
    error('You must specify a valid input directory!');
end

% First we create links to all relevant files in the OUTPUT_DIR
if ~isempty(opt.SubjectDiscardMissingResp),
    if numel(opt.SubjectDiscardMissingResp) > 1,
        subjRegex = join('|', opt.SubjectDiscardMissingResp);
    else
        subjRegex = num2str(opt.SubjectDiscardMissingResp);
    end
    
    regex = ['_0+(' subjRegex ')_.+_stg1\.pseth?$'];
    myFilesDiscardMR = finddepth_regex_match(opt.InputDir, regex);
    myFilesDiscardMR = link2files(myFilesDiscardMR, opt.OutputDir);
else
    myFilesDiscardMR = {};
end

if ~isempty(opt.SubjectIncludeMissingResp),
    if numel(opt.SubjectIncludeMissingResp) > 1,
        subjRegex = join('|', opt.SubjectIncludeMissingResp);
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