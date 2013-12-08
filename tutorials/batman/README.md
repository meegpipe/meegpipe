BATMAN tutorial
===============

Below I assume that you are running this tutorial at the _somerengrid_, i.e. at
one of the nodes from the private computing grid of the [Sleep&Cognition][sc]
team of the [Netherlands Institute for Neuroscience][nin].

[sc]: http://www.nin.knaw.nl/research_groups/van_someren_group
[nin]: http://www.nin.knaw.nl/


## Experimental data

### Experimental protocol

Description of the experimental protocol here...

![Experimental protocol](./img/batman-protocol.png "Experimental protocol")


## Objectives/Roadmap

1. [Getting the relevant raw data files][getting_raw].

2. [Splitting the large (20-30 Gb) files][splitting] into more manageable
   smaller files.

3. [Extract features from the Arterial Blood Pressure (ABP) data][abp-feat]
   contained in the BATMAN recordings. We want to get such features for each
   experimental manipulation and experimental task (`Baseline`, `PVT`,
   `RS`, and `RSQ`).

4. [Extract heart-rate variability (HRV) features][hrv-feat] from the [ECG][ecg]
   data, for each experimental manipulation and experimental task.

5. Getting [PVT response time statistics][pvt-feat] from the PVT response
   events, for each experimental manipulation and experimental task.

[getting_raw]: ./getting_raw_data.md
[splitting]: ./splitting_raw_data.md
[abp-feat]: ./abp_feat.md
[hrv-feat]: ./hrv_feat.md
[pvt-feat]: ./pvt_feat.md
[ecg]: http://en.wikipedia.org/wiki/Electrocardiography

