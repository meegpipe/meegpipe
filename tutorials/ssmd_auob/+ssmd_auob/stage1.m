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

myPipe = ssmd_auob.basic_preprocessing_pipeline(varargin{:});

run(myPipe, myFiles{:});

end
