function extract_temp_features(varargin)
% EXTRACT_TEMP_FEATURES - Extract temperature features from BATMAN data
%
% 

% Import some utilities
import mperl.file.find.finddepth_regex_match;
import misc.process_arguments;
import misc.split_arguments;

opt.Date     = datestr(now, 'yymmdd_HHMMSS');
opt.Subject  = 1:10; 
opt.Condition = {'arsq', 'baseline', 'pvt', 'rs'};
opt.OutputDir = '';

[thisArgs, varargin] = split_arguments(opt, varargin);
[~, opt] = process_arguments(opt, thisArgs, [], true);

if isempty(opt.OutputDir),
    opt.OutputDir = ['/data1/projects/batman/analysis/temp/'  opt.Date];
end

% Just in case you forgot to do it when you started MATLAB
meegpipe.initialize;

% Ensure the directory exists (Unix-specific)
system(['mkdir -p ' opt.OutputDir]);

myPipe = batman.extract_temp_features_pipeline(...
    varargin{:});

somsds.link2rec(...
    'batman',       ...                  % The recording ID
    'subject',      opt.Subject, ...     % The subject ID(s)
    'modality',     'eeg', ...           % The data modality
    'condition',    opt.Condition, ...
    'file_regex',   '\.pset', ...        % Only pset/pseth files
    'folder',       opt.OutputDir);


files = finddepth_regex_match(opt.OutputDir, '.pseth$');

run(myPipe, files{:});

end