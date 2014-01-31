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

The feature aggregation step is analogous to what we did when [aggregating the
ABP features][abp]. Just take a look at
[aggregate_hrv_features.m][aggregate_hrv_features].

[aggregate_hrv_features]: ./+batman/aggregate_hrv_features.m
[abp]: ./abp_feat.md


## [Continue to the next step ...][pvt]

[pvt]: ./pvt_feat.md
