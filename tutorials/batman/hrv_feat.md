HRV feature extraction
===

We will now extract Heart Rate Variability features from the [ECG][ecg]
time-series contained in the BATMAN recordings. This is done with the help of
[physionet]'s [HRV toolkit][hrv_toolkit].

[hrv_toolkit]: http://physionet.org/tutorials/hrv-toolkit/
[physionet]: http://physionet.org/


## Main processing script

The main script for extracting HRV features is practically identical to the
script that we used for [extracting the ABP features][abp]. Try to write the
script yourself before you take a look at the [one that
I wrote][extract_abp_feat].

[abp]: ./abp_feat.md
[extract_abp_feat]: ./+batman/extract_abp_features.m
