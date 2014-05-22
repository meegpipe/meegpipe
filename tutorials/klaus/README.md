meegpipe in a nutshell
=======

This tutorial has been prepared for a one-day workshop at the research 
group of [Klaus Linkenkaer-Hansen][klaus] at the 
[Center for Neurogenomics and Cognitive Research (CNCR)][cncr] of the
[VU University Amsterdam][vu]. The goal of this tutorial is to illustrate 
the basic functionality of _meegpipe_. 

[klaus]: http://www.cncr.nl/minor/brain_and_mind/coordinators/dr_klaus_linkenkaer-hansen
[cncr]: http://www.cncr.nl/
[vu]: http://vu.nl/en/


## Tutorial data

We will use a sample Eyes Open EEG recording (in [EEGLAB][eeglab]'s format).
Download the .zip file [NBT.S0021.090205.EOR1.zip](https://dl.dropboxusercontent.com/u/4479286/meegpipe/NBT.S0021.090205.EOR1.zip)
and extract its contents into your current working directory. In the 
rest of this tutorial I will assume that all commands are run within the 
same working directory. 

[eeglab]: http://sccn.ucsd.edu/eeglab/

## Preliminaries

You will need to [install meegpipe][meegpipe] and run this initialization
code:

````
% Replace with the relevant path for your system
addpath(genpath('/data1/toolbox/eeglab'));
meegpipe.initialize;
````


## Tutorial organization

The tutorial consists of two parts:

* The [first part][part1] illustrates the major characteristics of the data
  structure that _meegpipe_ uses to store physiological time-series (EEG,
  ECG, etc): the [physioset][physioset]. During this first part we will
  show  how _meegpipe_'s low-level functionality can be used to explore 
  interactively your data, and to process it using various filters. 

* The [second part][part2] describes how _meegpipe_ can be used to build 
  (possibly very complex) processing pipelines that (1) can be applied to 
  very large datasets, and (2) are suitable for parallel non-interactive 
  processing on a computing grid or in the cloud. 

[physioset]: ../../+physioset/@physioset/README.md
[part1]: ./part1.md
[part2]: ./part2.md




