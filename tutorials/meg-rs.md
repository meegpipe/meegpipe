Tutorial: cleaning resting state MEG data
========

This tutorial will show you how you can use _meegpipe_ to clean 
MEG data. For illustration purposes I will use resting state MEG 
data but the process would be very similar for task data. 

The raw data used in this tutorial is exceptionally clean, one of the 
easons being that the tSSS correction algorithm included in 
[Elekta's MaxFilter][maxfilter] had aready been applied to the data. Thus,
you should not expect to find huge differences between the raw data and
the data after cleaning. However, this is not usually the case, especially
when dealing with hdEEG.

[maxfilter]: http://www.megwiki.org/images/a/aa/MaxFilter-2.0.pdf

## Experimental data

The experimental data used in this tutorial was distributed to the invited
speakers to the [Amsterdam Brain Connectivity conference][abc] (ABC) that 
took place on April 2012. Please read the <a href="#credit">credits</a>
at the end of this tutorial for more information.


[abc]: http://amsterdambrainconnectivity.blogspot.nl/

The four data files that I will use are these:


* [abcg_0001_meg_rs-eo_1_tsss.fif.gz](http://kasku.org/data/abcg/abcg_0001_meg_rs-eo_1_tsss.fif.gz)
* [abcg_0001_meg_rs-eo_2_tsss.fif.gz](http://kasku.org/data/abcg/abcg_0001_meg_rs-eo_2_tsss.fif.gz)
* [abcg_0002_meg_rs-eo_1_tsss.fif.gz](http://kasku.org/data/abcg/abcg_0001_meg_rs-eo_1_tsss.fif.gz)
* [abcg_0002_meg_rs-eo_2_tsss.fif.gz](http://kasku.org/data/abcg/abcg_0001_meg_rs-eo_2_tsss.fif.gz)

These are just two sessions of resting state eyes open data from two different 
subjects.

### Working at somerengrid

If you are working at the somerengrid then you don't need to download the
files. Just open a terminal and type:

	mkdir ~/tutorial
	cd ~/tutorial
	somsds_link2rec abcg --modality eeg --condition rs-eo
	
The commands above will create symbolic links to the relevant data files
under `~/tutorial/abcg`. 


## Defining the cleaning pipeline

Our processing pipeline is going to consist of the following stages:

1. Data import (from Neuromag's `.fif`).
2. Remove data mean.
3. Downsample to 250 Hz.
4. High pass filter (0.5 Hz).
5. Re-referencing (average reference).
6. Remove powerline 50 Hz artifact.
7. Remove cardiac artifact.
8. Remove ocular activity ([EOG][artifacts-phys] artifacts).
9. Remove muscle activity ([EMG][artifacts-phys] artifacts).

Note that, contrary to what we have done in [other tutorials][eeg-erp-tut],
our pipeline does not include a node to reject bad channels or bad data 
samples. The reason is that this MEG dataset is so clean that both are
unnecessary. However, this is an exception rather than a rule. In most
scenarios (and especially in scenarios that involve hdEEG), you will want
to identify and reject bad data  before attempting fancier things such as
removing EOG artifacts.

Below is the code the implements the desired pipeline:


[eeg-erp-tut]: ./eeg-erp.md

[egi]: http://www.egi.com/research-division-research-products/eeg-systems
[artifacts-phys]: http://emedicine.medscape.com/article/1140247-overview#aw2aab6b3
[artifacts-extraphys]: http://emedicine.medscape.com/article/1140247-overview#aw2aab6b4

````matlab
eval(meegpipe.alias_import('nodes'));
import physioset.import.neuromag;
import report.plotter.io;
import pset.selector.sensor_class;
import meegpipe.node.bss_regr.*;
    
megSelector = sensor_class('Class', 'MEG');
myFilter    = filter.hpfilt('fc', 0.5/(250/2));

% This is just the last part of the pipeline
artifactsPipe = pipeline('NodeList', ...
	{...
	pwl(250), ...
	ecg(250), ...
	eog(250), ... 
    emg(250) ...	
	}, ...
	'IOReport', 	io, ...
	'DataSelector', megSelector);

% And this is the whole pipeline
myPipeline = pipeline('NodeList', ...
	{...
	physioset_import('Importer', neuromag), ...
	center, ...
	resample('DownsampleBy', 5), ... 
	tfilter('Filter', myFilter, 'DataSelector', megSelector), ...
	reref.avg('DataSelector', megSelector), ...
	artifactsPipe ...
	}, ...
	'Name',           'Tutorial pipeline', ...
	'Save',           true, ...
    'GenerateReport', false);
````

Property `Save` can be used to instruct a node to store the processed
output to a disk file. By default, `Save` is set to false, and the
processed data is simply returned as the output of method `run()`.

### Selecting sub-sets of data for processing

All data processing nodes have a `DataSelector` property. This property
can be set to `[]` or to a [pointset selector object][pset-selector]
object. By using the latter we can indicate that certain node should apply
only to a subset of the data that is fed to the node input. When we defined
our pipeline, we constructed a pointset selector object that selects only
channels whose associated sensor class is `EEG`:

````matlab
import pset.selector.sensor_class;
megSelector = sensor_class('Class', 'MEG');
````

[Package pset.selector][pset-selector] contains a few other selector
classes. You could also define your own very particular ways of selecting
data by defining a new class and making that class implement the
[pset.selector][pset-selector-ifc] interface. 


[aregr-node]: ../%2Bmeegpipe/%2Bnode/%2Baregr
[tfilter-node]: ../%2Bmeegpipe/%2Bnode/%2Btfilter
[pset-selector]: https://github.com/germangh/matlab_pset/tree/master/%2Bpset/%2Bselector
[pset-selector-ifc]: https://github.com/germangh/matlab_pset/blob/master/%2Bpset/%2Bselector/selector.m


### Input/Output reports

_meegpipe_ nodes are able to generate simple Input/Output reports that
compare the time and frequency domain properties of the input versus the
output of the node. Generating I/O reports is computationally demanding and
can slow down processing considerably. Because of that, no I/O report are
generated by default. However, you can activate I/O reporting by setting
the node property `IOReport` to a valid [report object][report-generic].
Function [report.plotter.io][report-plotter-io] produces one such object. 
You can also define your own completely personalized I/O reports, but
explaining how to do that is beyond the scope of this tutorial. 

[report-plotter-io]: https://github.com/germangh/matlab_report/blob/master/%2Breport/%2Bplotter/io.m
[report-generic]: https://github.com/germangh/matlab_report/tree/master/%2Breport/%2Bgeneric


## Processing the data files

````matlab
meegpipe.initialize; % Needed only once per MATLAB session
import misc.dir;
import mperl.file.spec.catfile;
myFiles = catfile('~/tutorial', dir('~/tutorial', 'fif.gz$'));
cleanData = run(myPipeline, myFiles);
````

In the code snippet above, I used the [dir][dir] and [catfile][catfile]
functions to produce a cell array with the names of the 4 `.fif.gz` files
that are to be processed. 
  
[dir]: https://github.com/germangh/matlab_misc/blob/master/%2Bmisc/dir.m
[catfile]: https://github.com/germangh/matlab_mperl/blob/master/%2Bmperl/%2Bfile/%2Bspec/catfile.m  
  
Command `run()` will store the processing results of each data file in separate 
directories. Namely:
	
	abcg_0001_meg_rs-eo_1_tsss.meegpipe/tutorial-pipeline-[cfg]_[usr]_[sys]
	abcg_0001_meg_rs-eo_2_tsss.meegpipe/tutorial-pipeline-[cfg]_[usr]_[sys]
	abcg_0002_meg_rs-eo_1_tsss.meegpipe/tutorial-pipeline-[cfg]_[usr]_[sys]
	abcg_0002_meg_rs-eo_2_tsss.meegpipe/tutorial-pipeline-[cfg]_[usr]_[sys]

Where `[cfg]` is a 6 characters long hash code, which identifies the
pipeline configuration. Then `[usr]` is the name of the user that executed 
command `run()`, and `[sys]` is a string identifying the operating system
and MATLAB version (e.g. `PCWIN64-R2011b`).

Within those directories you will find a pair of files with extensions 
`.pseth` and `.pset`. For example, in the first directory listed above 
you will find:

	abcg_0001_meg_rs-eo_1_tsss_tutorial-pipeline.pset
	abcg_0001_meg_rs-eo_1_tsss_tutorial-pipeline.pseth
	
The `.pset` file contain the actual data values while the `.pseth` file
contain the associated metadata (e.g. events, sensor information, etc).
You should take care of keeping the `.pset`/`.pseth` files together 
whenever you decide to move the processing results to some other location.



### HTML reports

By default, all processing nodes generate an HTML report with information regarding the
node operation. Some nodes produce very detailed reports (e.g. [bss_regr][bss-regr-node]
nodes), while others produce very minimalistic ones (e.g. [center][center-node]) nodes. 

The processing reports for each node can be found in the `remark` directory which is
itself located in the node output directory. For instance, the report associated with the
processing of file `abcg_0001_meg_rs-eo_1_tsss.fif` can be found at:
	    
	abcg_0001_meg_rs-eo_1_tsss.meegpipe/tutorial-pipeline-[cfg]_[usr]_[sys]/remark/index.html

You can access an online version of such report at this URL:

http://kasku.org/data/abcg/abcg_0001_meg_rs-eo_1_tsss.meegpipe/tutorial-pipeline-e51002_gomez_PCWIN64-R2011b/remark/


[bss-regr-node]: ../%2Bmeegpipe/%2Bnode/%2Bbss_regr
[center-node]: ../%2Bmeegpipe/%2Bnode/%2Bcenter
[psd-wiki]: http://en.wikipedia.org/wiki/Spectral_density

### Loading the processed data into MATLAB

Method `run()` returns the processing result as one or more physioset objects. However, 
if you set the `Save` property of your pipeline to true, then the same results are also 
stored within the pipeline output directory. In that case, you could clear your MATLAB 
workspace and load back the processed data for subject `0001`, session `1` in MATLAB:

````matlab
import physioset.*;
myData = physioset.load(...
	['abcg_0001_meg_rs-eo_1_tsss.meegpipe/tutorial-pipeline/' ...
	'tutorial-pipeline-[cfg]_[usr]_[sys]/' ...
	'abcg_0001_meg_rs-eo_1_tsss_tutorial-pipeline.pseth'])
````

The code snippet above was copied from the [output HTML report][output-rep] generated by
the tutorial pipeline.

[output-rep]: http://kasku.org/data/abcg/abcg_0001_meg_rs-eo_1_tsss.meegpipe/tutorial-pipeline-e51002_gomez_PCWIN64-R2011b/remark/node-output.htm

Once the data is loaded into MATLAB, you can display it using method [plot][plot-method]:

````matlab
% Select only a subset of channels
select(myData, 1:10:250);
plot(myData);
````

Note that, before plotting the data, we used method [select][select-method] to select 
only a subset of channels from the physioset object `myData`. You can undo the last 
data selection by using method [restore_selection][restore-selection-method]:

````matlab
assert(size(myData, 1) == 24)
restore_selection(myData, 1);
assert(size(myData, 1) == 308);
````

Or you could just remove any existing data selection using method 
[clear_selection][clear-selection-method]:

````matlab
clear_selection(myData);
% Will be true regardless of how many times we used select() on myData
assert(size(myData, 1) == 308);
````

[plot-method]: https://github.com/germangh/matlab_physioset/blob/master/%2Bphysioset/%40physioset/plot.m
[select-method]: https://github.com/germangh/matlab_physioset/blob/master/%2Bphysioset/%40physioset/select.m
[restore-selection-method]: https://github.com/germangh/matlab_physioset/blob/master/%2Bphysioset/%40physioset/restore_selection.m
[clear-selection-method]: https://github.com/germangh/matlab_physioset/blob/master/%2Bphysioset/%40physioset/clear_selection.m


## Manual tuning of runtime parameters

Quite a few nodes included with _meegpipe_ take important (automatic)
decisions during runtime that affect the final processing results. For
instance, nodes of class [bss_regr][bss-regr-node] automatically identify
noisy spatial components. Such automatic decisions are obviously not fail
proof, not even after you have configured your pipeline to suit your data
as well as possible.

You can manually tune runtime decisions taken by some nodes by editing the
runtime configuration file (an [.ini file][ini-file]) associated with each
processing node. The easiest way of doing this is to go to the HTML report
page that corresponds to that node, and copy and paste the MATLAB code that
it is indicated there. For instance, to modify the selection of EOG-related
spatial components for subject `0001`, session `1`, I had to copy and paste
the following code in MATLAB:

````matlab
edit(['C:/Users/gomez/Documents/My Dropbox/work/repo/workdir/' ...
        'abcg_0001_meg_rs-eo_1_tsss.meegpipe/' ...
        'tutorial-pipeline-e51002_gomez_PCWIN64-R2011b/node-6-pipeline/' ...
        'node-3-bss_regr-eog/node-3-bss_regr-eog.ini']); 
````

After running the command above, the following text file opens:

    [bss]
    seed=990640375
    init=NaN

    [window 1]
    selection= <<EOT
    [
    1  2  3  4  5
    ]
    EOT

The file is divided into two sections. Section `[bss]` stores runtime 
parameters related to the BSS algorithm, like the initialization (if 
applicable) and a random seed necessary to ensure perfect reproducibility 
of BSS results. Typically you will not want to modify the parameters of 
this section. In this particular case we run BSS on the whole dataset 
(i.e. we had a single analysis window) and thus there is just one 
additional section named `[window 1]`. If you had configured your pipeline
to run BSS in sliding windows then you would see a section for each 
analysis window. Within each `[window X]` section you would find the
indices of the spatial components that were rejected in that window (or
accepted, if you had set property `Reject` of the `bss_regr` node to 
`false`). 

You can just modify the contents of the file so that e.g. the sixth 
spatial component is also rejected:

    [bss]
    seed=990640375
    init=NaN

    [window 1]
    selection= <<EOT
    [
    1  2  3  4  5  6
    ]
    EOT


After the modification, save the file, and run the data processing again:

````matlab
run(myPipeline, '~/tutorial/abcg_0001_meg_rs-eo_1_tsss');
````

__IMPORTANT:__ You should not edit multiple node runtime configurations
before running again `run()`. Indeed, modifying the runtime configuration
of a node invalidates the runtime configuration of any subsequent node. 
The reason is simple, modifying the runtime decisions of node `X` will 
potentially modify the output of node `X`, and therefore the input to any
subsequent node, rendering runtime decisions taken in those nodes 
obsolete.  

It is up to you to decide how much manual tuning gives you a good 
compromise between automation and accuracy. You should also take into
consideration the fact that manual intervention introduces certain degree
of subjectivity into your analyses. Thus, it might be difficult to justify
to others (or to yourself after a few months have passed) why this or that
component had to be rejected/accepted. 

Personally, I try to minimize manual intervention as much as possible by
spending quite some time tuning the pipeline configuration so that the
number of mistakes made by the nodes during runtime is brought down to an
_acceptable_ value. The underlying philosophy is that MEG, and especially
hdEEG, contain lots of noise and the only goal of a data cleaning pipeline
is to improve the signal-to-noise ratio. The goal is not to remove all
noise, neither to avoid loosing any signal at all, but simply to increase
the power ratio between signal and noise. 

[ini-file]: http://en.wikipedia.org/wiki/INI_file


## Exporting the processed data

Typically, you will want to futher process/analyze your data using another 
toolbox. To convert to [EEGLAB][eeglab] or [Fieldtrip][ftrip] format:

`````matlab
myEeglabdata = eeglab(myData);
myFtripData  = fieldtrip(myData);
````

[eeglab]: http://sccn.ucsd.edu/eeglab/
[ftrip]: http://fieldtrip.fcdonders.nl/


## Credit

<a name="credit"></a>The data was acquired at the MEG scanner of the 
[VU University Medical Center][vumc] in Amsterdam, The Netherlands. Both
[Kees Stam][stam] and [Arjan Hillebrand][arjan] should be acknowledged for
providing the scanning facilities. 

The experiment was designed at the group of [Mike X Cohen][mike] of the
 [University of Amsterdam][mike-group]. The actual data acquisition was
performed by [Irene van de Vijver][irene] and [Sara Jahfari][sara]. Please
 contact [Mike X Cohen][mike] if you would like to use this dataset in any
of your publications.

[arjan]: http://www.neurosciencecampus-amsterdam.nl/en/people/staff-a-z/staff-g-h/hillebrand/index.asp
[stam]: http://www.neurosciencecampus-amsterdam.nl/en/people/staff-a-z/staff-s-t/stam/index.asp
[vumc]: http://www.vumc.com/
[irene]: http://home.medewerker.uva.nl/i.vandevijver/
[sara]: http://www.sarajahfari.com/
[mike]: http://www.mikexcohen.com/
[mike-group]: http://sincs.nl/


