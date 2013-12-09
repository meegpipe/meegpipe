`ssmd_rs` tutorial
===

Below I assume that you are running this tutorial at the _somerengrid_, i.e. at
one of the nodes from the private computing grid of the [Sleep&Cognition][sc]
team of the [Netherlands Institute for Neuroscience][nin].

[sc]: http://www.nin.knaw.nl/research_groups/van_someren_group
[nin]: http://www.nin.knaw.nl/


## Experimental data

### Experimental protocol

A description of the experimental protocol should be here at some point...

The purpose of this tutorial is to illustrate how to use _meegpipe_ to clean
the 5-minutes eyes open and eyes closed hdEEG recordings that were obtained as
part of the _ssmd_ protocol.

## Objectives/Roadmap

1. [Removing large amplitude trends in the data][removing_trends] with
   a [LASIP][lasip] filter. An alternative to this approach would be to
   simply high-pass filter the raw hdEEG data. However, low-pass filtering often
   introduces considerable border-artifacts and may note remove completely rapid
   signal trends (e.g. caused by large movements or by the sensors suddenly
   loosing contact with the skin).

