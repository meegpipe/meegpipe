function data = stage3(varargin)
% STAGE3 - ERP computation
%
% stage3('option1', val1, 'option2', val2, ...)
%
% Where 'optionX', valX, are optional parameters. See below for a list of
% the options that are recognized by this function. Any non-recognized
% option will be passed directly to the pipeline associated to stage1
% (ssmd_auob.artifact_correction_pipeline). 
%
% ## Accepted arguments (as key/value pairs):
%
% Subject              :   (numeric array) Default: setdiff(1:500, [151 152])
%                          An array of subjects IDs for which the ERPs
%                          should be computed.
%
% DiscardMissingResp   :  (logical) Default: true
%                          Should events with missing responses be
%                          discarded and not used for ERP computation?
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
% % Compute the ERP for all subjects but do not discard missing responses
% % subjects 151 and 152. Also, run the processing jobs at 'long.q' instead
% % of at the default OGE queue ('short.q'):
%
% stage3('Subject', [151 152], 'DiscardMissingResp', false, 'Queue', 'long.q');
%
%
% See also: ssmd_auob.erp_pipeline, ssmd_auob.stage2

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
opt.DiscardMissingResp      = true;
opt.Subject                 = setdiff(1:500,[151 152]); 
opt.InputDir                = '';
opt.OutputDir               = ...
    ['/data1/projects/ssmd-erp/analysis/stage3/' datestr(now, 'yymmdd-HHMMSS')];

[thisArgs, varargin] = split_arguments(opt, varargin);
[~, opt] = process_arguments(opt, thisArgs);

if isempty(opt.DiscardMissingResp),
    opt.DiscardMissingResp =  setdiff(1:500, opt.IncludeMissingResp);
end

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

regex = ['_0+(' subjRegex ')_.+_stg2\.pseth?$'];
files = finddepth_regex_match(opt.InputDir, regex);
link2files(files, opt.OutputDir);

% Now we can group the links that belong to the same subject and different
% blocks
allFiles = {};

for i = 1:numel(opt.Subject)   
    % A regular expression that matches the names of all the files
    % that we want to merge for this subject
    regex = ['_0+' num2str(opt.Subject(i)) '_.+_stg2\.pseth$'];
   
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
    'DiscardMissingResp',   opt.DiscardMissingResp, ...
    varargin{:});

data = run(myPipe, allFiles{:});