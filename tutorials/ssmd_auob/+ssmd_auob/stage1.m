function stage1(varargin)
% STAGE1 - Basic preprocessing: bad data rejection, filtering, ...
%
% stage1('option1', val1, 'option2', val2, ...)
%
% Where 'optionX', valX, are optional parameters. See below for a list of
% the options that are recognized by this function. Any non-recognized
% option will be passed directly to the pipeline associated to stage1
% (ssmd_auob.basic_preprocessing_pipeline). 
%
% ## Accepted arguments (as key/value pairs):
%
% Subject   :   (numeric array) Default: 1:1000
%               The IDs of the subjects to be processed
%
% OutputDir :   (string) Default: ['/data1/projects/ssmd-erp/analysis/stage1/' datestr(now, 'yymmdd-HHMMSS')]
%               The full path to the directory where the processing results
%               (the .meegpipe directories) should be produced.
%
%
% ## Usage examples:
%
% % Run analysis for subjects 135, 147, and 153, and use 'stage1' as the
% % name of the pipeline (instead of the default 'stg1'), and send the jobs
% % to queue short.q@nin174.herseninstituut.knaw.nl. Notice that option
% % Subject is processed by ssmd_auob.stage1, but the other options are
% % processed by ssmd_auob.basic_preprocessing_pipeline.
%
% % Adding EEGLAB and meegipe to the path, and initializing meegpipe is
% % needed only once per MATLAB session
% addpath('meegpipe'); % assumes meegpipe' dir is under the current dir
% addpath('/data1/toolbox/eeglab');
% meegpipe.initialize;
% ssmd_auob.stage1('Subject', [135 147 153], 'Name', 'stage1', ...
%   'Queue', 'short.q@nin174.herseninstituut.knaw.nl');
%
%
% See also: ssmd_auob.basic_preprocessing_pipeline, ssmd_auob.stage2

meegpipe.initialize;

import mperl.file.spec.*;
import mperl.file.find.*;
import somsds.link2files;
import mperl.join;
import misc.process_arguments;
import misc.split_arguments;

opt.Subject                 = 1:1000;
opt.OutputDir               = ['/data1/projects/ssmd-erp/analysis/stage1/' datestr(now, 'yymmdd-HHMMSS')];

[thisArgs, varargin] = split_arguments(opt, varargin);
[~, opt] = process_arguments(opt, thisArgs);

myFiles  = somsds.link2rec('ssmd', ...
    'modality',     'eeg', ...
    'condition',    'auob', ...
    'file_ext',     '.mff', ...
    'subject',      opt.Subject, ...
    'folder',       opt.OutputDir);

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

myPipe = ssmd_auob.basic_preprocessing_pipeline(...
    'Name', 'stg1', varargin{:});

run(myPipe, myFiles{:});

end
