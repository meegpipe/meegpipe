function aggregate_features(type, varargin)
% AGGREGATE_FEATURES - Aggregate PVT, ABP, ECG, etc. features across files

import meegpipe.aggregate2;
import misc.dir;
import mperl.file.spec.catfile;
import misc.get_hostname;
import misc.process_arguments;
import misc.find_latest_dir;


if nargin < 1 || isempty(type),
    error('Please provide the name of the features that should be aggregated');
end

if ~ismember(type, {'abp', 'pvt', 'temp'}),
    error('feature type must be any of: abp, pvt, temp');
end

opt.OutputDir = '';
[~, opt] = process_arguments(opt, varargin);

if isempty(opt.OutputDir),
    opt.OutputDir = find_latest_dir(['/data1/projects/batman/analysis/' type]);
end

% We need to build a cell array with the names of all .pseth files that were
% used as input to the feature extraction pipeline
regex = 'batman_0+\d+_eeg_.+\d\.pseth$';
files = dir(opt.OutputDir, regex);
files = catfile(opt.OutputDir, files);

% A pattern that matches the feature text files within the .meegpipe dirs
regex = ['batman-' type '-.+features.txt$'];

% The name of the .csv file where the joint feature table will be stored
outputFile = catfile(opt.OutputDir, [type '_features.csv']);

if isempty(files),
    warning('aggregate_features:NoFilesFound', ...
        'No files matched the pattern: no features were aggregated');
end

aggregate2(files, regex, outputFile, @batman.fname2meta);



end