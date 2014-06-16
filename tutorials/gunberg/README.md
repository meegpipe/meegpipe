`tmsi_eeg` tutorial
===

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
need to install all of _meegpipe_'s [highly recommended dependencies][deps].

[meegpipe]: http://meegpipe.github.io/meegpipe/
[deps]: https://github.com/meegpipe/meegpipe/blob/master/recommended.md


## Dataset 

* Raw data: [export_25-11_calibratie.Poly5][dataurl]
* Sensor coordinates: [export_25-11_calibratie.sensors][sensorsurl]

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
three consecutive stages (or sub-pipelines):

1. Pipeline [grunberg.preprocess_pipeline][preproc-pipe] involves basic 
preprocessing steps such as bad channels and bad epochs rejection, as well as a
removing high-amplitude high-frequency signal fluctuations (using a 
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

## Manual selection of noisy independent components

The last sub-pipeline above requires the user to manually identify noisy independent 
components. The HTML reports produced by `grunberg.main` contain (in most cases) enough
 information for a human expert to decide which components should be attributed to noise
sources. Once the set of noisy components has been identified, you can instruct 
__meegpipe__ to reject that set of components by editing the relevant `.ini` file, as
 described in the HTML report of the corresponding processing node. After editing the 
 `.ini` file you need to re-run `grunberg.main` for the manual selection of components to
 take effect. 


## Inspect the processed and raw data files

Once the processing is completed, you can load into MATLAB the raw data file and
 the corresponding processing result as [Fieldtrip][fieldtrip] structures:

[fieldtrip]: http://fieldtrip.fcdonders.nl/

````
tmp = load(rawFiles{1});
rawData = tmp.ftripData;
tmp = load(processedFiles{1});
processedData = tmp.ftripData;
````

Note that the processed dataset is shorter than the original dataset, since 
the bad data epochs have been removed from the data. Alternatively, you may 
choose to leave the bad data epochs (as they were in the original data) but to 
mark them using `discontinuity` events: 

````matlab
[rawFiles, processedFile] = grunberg.main('BadDataPolicy', 'donothing');
````

You could also decide to zero out all bad data epochs:

````matlab
[rawFiles, processedFile] = grunberg.main('BadDataPolicy', 'flatten');
````