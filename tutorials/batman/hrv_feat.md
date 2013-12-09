HRV feature extraction
===

We will now extract Heart Rate Variability features from the [ECG][ecg]
time-series contained in the BATMAN recordings. This is done with the help of
[physionet]'s [HRV toolkit][hrv_toolkit].

[ecg]: http://en.wikipedia.org/wiki/Electrocardiography
[hrv_toolkit]: http://physionet.org/tutorials/hrv-toolkit/
[physionet]: http://physionet.org/


## Main processing script

The main script for extracting HRV features is practically identical to the
script that we used for [extracting the ABP features][abp]. Try to write the
script yourself before you take a look at the [one that
I wrote][extract_abp_feat].

[abp]: ./abp_feat.md
[extract_abp_feat]: ./+batman/extract_abp_features.m


## Processing pipeline

Try to write the HRV feature extraction pipeline yourself. Hints:

* Node [ecg_annotate][ecg_annotate] can be used to extract HRV features from an
  ECG time-series, as long as the locations of the R-peaks are annotated with
  suitable events.

[ecg_annotate]: ../../+meegpipe/+node/+ecg_annotate/README.md

* Node [qrs_detect][qrs_detect] detects R-peaks in an ECG time series and
  annotates them by placing `qrs` events at the corresponding locations.

[qrs_detect]: ../../+meegpipe/+node/+qrs_detect/README.md

If you feel lazy, or you think that this is too easy, you can also just take a
look at [the pipeline that I wrote][mypipe].

[mypipe]: ./+batman/extract_hrv_features_pipeline.m


## Aggregate features across single-block files

The feature aggregation step is identical to what we did when [aggregating the
ABP features][abp]:

[abp]: ./abp_feat.md

````matlab
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
````

To perform the aggregation simply run:

````matlab
batman.aggregate_abp_features
````

## [Continue to the next step ...][pvt]

[pvt]: ./pvt_feat.md
