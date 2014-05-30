`tmsi_eeg` tutorial
===

__This tutorial is still under construction__

A sample use case of meegpipe for importing and pre-processing EEG data 
acquired by a portable [TMSi EEG amplifier][tmsi-eeg].

[tmsi-eeg]: http://www.tmsi.com/en/applications/electroencephalography.html 

## Preliminaries

You will need to [install meegpipe][meegpipe] in order to run the scripts
that are part of this tutorial. You only need a minimal installation 
in order to get the cleaning results:

[meegpipe]: http://germangh.com/meegpipe

````
% installDir is where meegpipe will be installed
installDir = [pwd filesep 'meegpipe'];
url = 'https://github.com/meegpipe/meegpipe/zipball/master';
unzip(url, installDir);
% If you start a new MATLAB session you will need to run these two commands again
% You may want to add them to your MATLAB startup script
addpath(genpath('meegpipe'));
meegpipe.initialize;
````

If you also want to get the processing reports in HTML format then you will also
need to install all of _meegpipe_'s [optional dependencies][optdep].

[meegpipe]: http://meegpipe.github.io/meegpipe/
[optdep]: ../../../optional.md


## Dataset 

Raw data: [export_25-11_calibratie.Poly5][dataurl]
Sensor coordinates: [export_25-11_calibratie.sensors][sensorsurl]

[dataurl]: https://dl.dropboxusercontent.com/u/4479286/export_25-11_calibratie.Poly5
[sensorsurl]: https://dl.dropboxusercontent.com/u/4479286/export_25-11_calibratie.sensors


## Pre-processing/cleaning the data

Ensure that both the raw data file ([export_25-11_calibratie.Poly5][dataurl])
and the corresponding sensors coordinates file 
([export_25-11_calibratie.sensors][sensorsurl]) can be found in your 
current working directory. Then run:

````matlab
[rawFiles, processedFile] = grunberg.main;
% If you do not want the processing reports, then run instead:
% processedFiles = grunberg.main('GenerateReport', false);
````

The data cleaning procedure implemented by `grunberg.main` is very complex
 due to the fact that the sample dataset is __very noisy__. It is composed of
three consecutive stages:

1. Pipeline [grunberg.preprocess_pipeline][preproc-pipe] involves basic 
preprocessing steps such as bad channels and bad epochs rejection, as well as a
filter to remove high-amplitude high-frequency signal fluctuations (a 
[LASIP][lasip] filter).

2. Pipeline [grunberg.artifact_rejection_pipeline][artifact-pipe] is a fully
automated pipeline that uses [Blind Source Separation][bss] to identify and
reject spatio-temporal components that can be attributed to various sources:
cardiac noise, ocular activity, and electrode-specific noise sources. 

3. Pipeline [grunberg.supervised_bss_pipeline][supervised-pipe] is a fully 
supervised pipeline that, after performing BSS, requires the user to manually
select spatio-temporal components that should be removed from the data.

[lasip]: http://www.cs.tut.fi/~lasip/
[preproc-pipe]: ./+grunberg/preprocess_pipeline.m
[bss]: http://en.wikipedia.org/wiki/Blind_signal_separation
[artifact-pipe]: ./+grunberg/artifact_rejection_pipeline.m
[supervised-pipe]: ./+grunberg/supervised_bss_pipeline.m

## Inspect the processed and raw data files

Once the processing is completed, you can load the first raw data file and the
 corresponding processing result into [EEGLAB][eeglab]:

[eeglab]: http://sccn.ucsd.edu/eeglab/

````
eeglab; % Start EEGLAB
load(rawFiles{1}, '-mat');
[ALLEEG EEG] = eeg_store(ALLEEG, EEG, CURRENTSET);
load(processedFiles{1}, '-mat');
[ALLEEG EEG] = eeg_store(ALLEEG, EEG, CURRENTSET);
eeglab redraw;
````

Note that the processed dataset still contains the bad data epochs, which are 
completely unprocessed. The onset and durations of such epochs are marked with 
events of type `__BadEpoch`. If you prefer the bad epochs to be zeroed out 
before exporting to EEGLAB's data format, you should run:

````matlab
[rawFiles, processedFile = grunberg.main('BadDataPolicy', 'flatten');
````

Alternative, you may choose the bad data epochs to be removed from the data 
(i.e. good data before and after a bad data epoch will be concatenated):

````matlab
[rawFiles, processedFile = grunberg.main('BadDataPolicy', 'reject');
````