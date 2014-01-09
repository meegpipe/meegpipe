function aggregate_hrv_features
% AGGREGATE_HRV_FEATURES - Aggregate all HRV features in a single .csv table

% Some utilities that we use below
import meegpipe.aggregate2;
import misc.dir;
import mperl.file.spec.catfile;
import misc.get_hostname;

% The directory where the .meegpipe directories are located
switch lower(get_hostname)
    case {'somerenserver', 'nin389'}
        OUTPUT_DIR = '/data1/projects/meegpipe/batman_tut/gherrero/extract_hrv_features_output';
    otherwise
        OUTPUT_DIR = '/Volumes/DATA/tutorial/batman/extract_hrv_features_output';
end

% This is the function that we use to translate file names into meta-info tags
FILENAME_TRANS = @batman.fname2meta;

% We need to build a cell array with the names of all .pseth files that were
% used as input to the feature extraction pipeline
regex = 'batman_0+\d+_eeg_all_.+_\d+\.pseth$';
files = dir(OUTPUT_DIR, regex);
files = catfile(OUTPUT_DIR, files);

% A pattern that matches the feature text files within the .meegpipe dirs
FEAT_FILE_REGEX = 'batman-hrv-.+features.txt$';

% The name of the .csv file where the joint feature table will be stored
outputFile = catfile(OUTPUT_DIR, 'hrv_features.csv');

aggregate2(files, FEAT_FILE_REGEX, outputFile, FILENAME_TRANS);

end