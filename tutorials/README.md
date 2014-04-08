meegpipe tutorials
========

The tutorials that you will find here are not necessarily toy examples but,
often, they real use-cases of analysis and data processing tasks performed at
the [Sleep&Cognition][sc] team of the
[Netherlands Institute for Neuroscience][nin]. Thus, some of these materials are
fairly advanced and you are strongly encouraged to first read
[meegpipe's documentation][meegpipe-api].

__IMPORTANT:__ These materials were originally designed for internal use within
the [Netherlands Institute for Neuroscience][nin]. Thus, the raw data files used
in the tutorials may not be publicly available.

[meegpipe-api]: ../+meegpipe/README.md
[sc]: http://www.nin.knaw.nl/research_groups/van_someren_group
[nin]: http://www.nin.knaw.nl/


* The [BATMAN physiology tutorial][batman] illustrates the procedure for
  extracting signal features from Arterial Blood Pressure,
  Electroencephalography (ECG) and task-response events. The tutorial raw data
  is not yet publicly available. If you wonder about the funny name of this
  tutorial, it is due to the acronym of a related
  [research project][batman-project] that we are carrying out at the NIN.

[batman-project]: http://www.neurosipe.nl/project.php?id=23&sess=6eccc41939665cfccccd8c94d8e0216f

* The [ssmd_rs tutorial][ssmd_rs] illustrates a typical pre-processing and
  data-cleaning workflow in a resting-state [hdEEG][hdeeg] study. The raw data
  is not publicly available yet. This tutorial is still work in progress.

[batman]:  ./batman/README.md
[ssmd_rs]: ./ssmd_rs/README.md
[hdeeg]: http://en.wikipedia.org/wiki/Electroencephalography

* The [EOG regression tutorial][eog-tut] demonstrates how _meegpipe_ can be used
  to minimize ocular artifacts in the EEG using a classical technique:
  regressing out one or more reference EOG signals acquired with peri-ocular
  electrodes. The raw data used in this tutorial is publicly available. Moreover
  this tutorial is so simple that is should be trivial to follow all the steps
  using your own dataset.

* The [EMG correction tutorial][emg-tut] is a very simple illustration of how
  _meegpipe_ can be used to minimize muscle artifacts in the EEG.

[eog-tut]: ./eog/README.md
[emg-tut]: ./emg/README.md
