function data = stage3(varargin)

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
opt.OutputDir               = ...
    ['/data1/projects/ssmd-erp/analysis/stage3/' datestr(now, 'yymmdd-HHMMSS')];

[thisArgs, varargin] = split_arguments(opt, varargin);
[~, opt] = process_arguments(opt, thisArgs);

if isempty(opt.InputDir),
   % use the latest dir under /data1/projects/ssmd-erp/analysis/stage2
   opt.InputDir = find_latest_dir(...
       '/data1/projects/ssmd-erp/analysis/stage2');
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

regex = ['_0+(' subjRegex ')_.+_stage2\.pseth?$'];
files = finddepth_regex_match(opt.InputDir, regex);
link2files(files, opt.OutputDir);

% Now we can group the links that belong to the same subject and different
% blocks
allFiles = {};

for i = 1:numel(opt.Subject)   
    % A regular expression that matches the names of all the files
    % that we want to merge for this subject
    regex = ['_0+' num2str(opt.Subject(i)) '_.+_stage2\.pseth$'];
   
    % We now find the links that we just generated above
    files = finddepth_regex_match(opt.OutputDir, regex);
    files = sort(files);
    
    if ~isempty(files),
        fprintf('(stage3) Found %d files for subject %d ...\n\n', ...
            numel(files), opt.Subject(i));
        
        allFiles = [allFiles;{files}]; %#ok<*AGROW>      
    end    
end

%% Run the pipeline
myPipe = ssmd_auob.erp_pipeline(...
    'Name',                 'stg3', ...
    'Queue',                'short.q', ...
    'OGE',                  true, ...
    'GenerateReport',       true, ...
    'DiscardMissingResp',   opt.DiscardMissingResp, ...
    varargin{:});

data = run(myPipe, allFiles{:});