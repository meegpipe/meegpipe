BATMAN tutorial
===

This tutorial illustrates a real data processing use-case that was performed
within the [BATMAN project][batman-proj]. Below I assume that you are following
this tutorial at the _somerengrid_, i.e. at one of the nodes from the private
computing grid of the [Sleep&Cognition][sc] team of the
[Netherlands Institute for Neuroscience][nin].

[batman-proj]: http://www.neurosipe.nl/project.php?id=23&sess=6eccc41939665cfccccd8c94d8e0216f
[sc]: http://www.nin.knaw.nl/research_groups/van_someren_group
[nin]: http://www.nin.knaw.nl/


## Experimental data


The BATMAN (Behavior, Alertness, and Thermoregulation: a Multivariate ANalysis)
project pursues to identify major thermoregulatory system parameters, and their
effects on behaviour and alertness, in a completely unrestrained ambulatory
setting. Achieving this goal will involve ambulatory measurement of all relevant
inputs and outputs: physical activity, posture, environmental light and
body temperature, electrocardiography, and skin temperature by means of a
multi-sensor system as well as questionnaires and reaction times assessed on a
PDA. These parameters will be validated against those derived under strictly
controlled laboratory manipulations.

This tutorial deals with the extraction of valuable features (for modeling
purposes) from the laboratory recordings obtained within the BATMAN project.


### Experimental protocol

In a nutshell, the BATMAN protocol involved various environmental manipulations
(posture, skin temperature, ambient lights) that are expected to trigger
relevant thermoregulatory system responses. Such responses were characterized
using a diverse set of variables: arterial blood pressure, ECG, skin and core
temperature, and hdEEG. In order to assess effects on behavior and alertness, the
subjects performed a PVT response-time task, and filled the Amsterdam Resting
State Questionnaire while being subjected to these experimental manipulations.
In total there were 12 experimental blocks, as illustrated in the diagram below:

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

