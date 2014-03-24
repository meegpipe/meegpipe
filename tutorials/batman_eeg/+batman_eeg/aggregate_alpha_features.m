function aggregate_alpha_features(varargin)
% AGGREGATE_ALPHA_FEATURES - Aggregate feature files across .meegpipe dirs

import meegpipe.aggregate2;
import misc.dir;
import mperl.file.spec.catfile;
import misc.get_hostname;
import misc.process_arguments;
import misc.find_latest_dir;

opt.Type = {'brainloc', 'psd_peak', 'psd_ratio', 'thilbert', 'topo_full'};
opt.OutputDir = '';
[~, opt] = process_arguments(opt, varargin);

if isempty(opt.OutputDir),
    opt.OutputDir = find_latest_dir('/data1/projects/batman/analysis/alpha_features');
end

% We need to build a cell array with the names of all .pseth files that were
% used as input to the feature extraction pipeline
regex = 'batman_0+\d+_eeg_.+\d_cleaning-pipe\.pseth$';
files = dir(opt.OutputDir, regex);
files = catfile(opt.OutputDir, files);

if isempty(files),
    warning('aggregate_alpha_features:NoFilesFound', ...
        'No files matched the pattern: no features were aggregated');
end

for i = 1:numel(opt.Type)
    % A pattern that matches the feature text files within the .meegpipe dirs
    regex = ['features_spt\.feature\.' opt.Type{i} '.txt$'];
    
    % The name of the .csv file where the joint feature table will be stored
    outputFile = catfile(opt.OutputDir, ['features_' opt.Type{i} '.csv']);
    
    aggregate2(files, regex, outputFile, @batman_eeg.fname2meta);
    
end

end