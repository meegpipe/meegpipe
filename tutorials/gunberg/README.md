`tmsi_eeg` tutorial
===

This tutorial is still on the making!

A sample use case of meegpipe for importing and pre-processing EEG data 
acquired by a portable TMSi EEG amplifier.

## Preliminaries

You will need to [install meegpipe][meegpipe] in order to run the scripts
that are part of this tutorial. You only need a minimal installation 
in order to get the cleaning results. If you also want to get 
the processing reports in HTML format then you will also need all of
_meegpipe_'s [optional dependencies][optdep].

[meegpipe]: http://meegpipe.github.io/meegpipe/
[optdep]: ../../../optional.md


## Dataset 

Raw data: [export_25-11_calibratie.Poly5][dataurl]
Sensor coordinates: [export_25-11_calibratie.sensors][sensorsurl]


[dataurl]: https://dl.dropboxusercontent.com/u/4479286/export_25-11_calibratie.Poly5
[sensorsurl]: https://dl.dropboxusercontent.com/u/4479286/export_25-11_calibratie.sensors


## Pre-processing the data

Ensure that both the raw data file ([export_25-11_calibratie.Poly5][dataurl])
and the corresponding sensors coordinates file 
([export_25-11_calibratie.sensors][sensorsurl]) can be found in your 
current working directory. Then run:

````matlab
[myPipe, myFiles] = grunberg.main
````

When the processing is completed, the path to the output dataset (in 
EEGLAB format) is:

````
import mperl.file.spec.catfile;
outputDir = get_root_dir(myPipe, myFiles{1});
outputFile = mperl.file.find.finddepth_regex_match(outputDir, '\.set$');   
````

You can then load it into EEGLAB using:

````
eeglab; % Start EEGLAB
load(outputFile, '-mat');
[ALLEEG EEG] = eeg_store(ALLEEG, EEG, CURRENTSET);
eeglab redraw;
````
