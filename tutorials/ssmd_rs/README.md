`ssmd_rs` tutorial
===

Below I assume that you are running this tutorial at the _somerengrid_, i.e. at
one of the nodes from the private computing grid of the [Sleep&Cognition][sc]
team of the [Netherlands Institute for Neuroscience][nin].

[sc]: http://www.nin.knaw.nl/research_groups/van_someren_group
[nin]: http://www.nin.knaw.nl/

I also assume that you have run the following code when you started MATLAB:

````matlab
% Ensure MATLAB's workspace is completely clean
close all; clear all; clear classes

% Ensure no interfering toolboxes are in MATLAB's search path
restoredefaultpath;

% Add meegpipe to MATLAB's search path
addpath(genpath('/data1/toolbox/meegpipe'));
````

## Experimental data

### Experimental protocol

A description of the experimental protocol should be here at some point...

The purpose of this tutorial is to illustrate how to use _meegpipe_ to clean
the 5-minutes eyes open and eyes closed hdEEG recordings that were obtained as
part of the _ssmd_ protocol.

## Objectives/Roadmap

1. [Removing large amplitude trends in the data][removing_trends]. These
   large trends may be caused by movements or by the sensors suddenly
   loosing contact with the skin.

2. [Removing artifacts][artifacts]

[artifacts]: ./removing_artifacts.md
[removing_trends]: ./removing_trends.md

