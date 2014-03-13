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
opt.Subject                 = setdiff(1:200, [151 152]);
opt.DiscardMissingResp      = true;
opt.Queue                   = 'short.q';    
opt.InputDir                = '';
opt.OutputDir               = ['/data1/projects/ssmd-erp/analysis/stage2/' datestr(now, 'yymmdd-HHMMSS')];

[thisArgs, varargin] = split_arguments(opt, varargin);
[~, opt] = process_arguments(opt, thisArgs);

if isempty(opt.InputDir),
   % use the latest dir under /data1/projects/ssmd-erp/analysis/stage1
   opt.InputDir = find_latest_dir(...
       '/data1/projects/ssmd-erp/analysis/stage1');
end

if isempty(opt.InputDir) || ~exist(opt.InputDir, 'dir')
    error('You must specify a valid output directory!');
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

fprintf('\n\nGoing to process %d file(s):\n', numel(myFiles));
fprintf('%s\n', myFiles{1});
if numel(myFiles) > 1,
    fprintf('...\n');
    fprintf('%s\n\n', myFiles{end});
end
fprintf('\nPress CTRL+C to cancel or any other key to proceed ...\n');
pause;

%% Run the pipeline
myPipe = ssmd_auob.artifact_correction_pipeline(...
    'Name',  'stg2', varargin{:});

data = run(myPipe, myFiles{:});


end