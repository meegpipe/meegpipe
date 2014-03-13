function stage1(varargin)

meegpipe.initialize;

import mperl.file.spec.*;
import mperl.file.find.*;
import somsds.link2files;
import mperl.join;
import misc.process_arguments;
import misc.split_arguments;

opt.Subject                 = 1:1000;
opt.Queue                   = 'short.q';
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
