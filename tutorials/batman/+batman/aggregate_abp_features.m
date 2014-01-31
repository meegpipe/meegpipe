function aggregate_abp_features
% AGGREGATE_ABP_FEATURES - Aggregate all ABP features in a single .csv table

% Some utilities that we use below
import meegpipe.aggregate2;
import misc.dir;
import mperl.file.spec.catfile;
import misc.get_hostname;

% The directory where the .meegpipe directories from the splitting stage are
% located. Change this to match the path in your system.
OUTPUT_DIR = '/data1/projects/meegpipe/batman_tut/gherrero/extract_abp_features_output

% This is the function that we use to translate file names into meta-info tags
FILENAME_TRANS = @batman.fname2meta;

% We need to build a cell array with the names of all .pseth files that were
% used as input to the feature extraction pipeline
regex = 'batman_0+\d+_eeg_all_.+_\d+\.pseth$';
files = dir(OUTPUT_DIR, regex);
files = catfile(OUTPUT_DIR, files);

% A pattern that matches the feature text files within the .meegpipe dirs
FEAT_FILE_REGEX = 'batman-abp-.+features.txt$';

% The name of the .csv file where the joint feature table will be stored
outputFile = catfile(OUTPUT_DIR, 'abp_features.csv');

aggregate2(files, FEAT_FILE_REGEX, outputFile, FILENAME_TRANS);

end