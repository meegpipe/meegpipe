meegpipe
========

_meegpipe_ is a collection of MATLAB tools for building advanced processing
pipelines for high density physiological recordings. It is especially
suited for the processing of high-density [EEG][eeg] and [MEG][meg],
but can also handle other modalities such as [ECG][ecg], temperature,
[actigraphy][acti], light exposure, etc.


[gg]: https://groups.google.com/forum/#!forum/meegpipe
[ggh]: http://germangh.com
[eeg]: http://en.wikipedia.org/wiki/Electroencephalography
[meg]: http://en.wikipedia.org/wiki/Magnetoencephalography
[ecg]: http://en.wikipedia.org/wiki/Electrocardiography
[acti]: http://en.wikipedia.org/wiki/Actigraphy

In the documentation below I often assume a Linux-like system (e.g. use of
frontslashes, `~` to denote home directory, etc). However, _meegpipe_ should
also run under Windows. If you are using Windows, some of the commands that
appear below might need minor modifications like replacing `~` by your home
directory name.


## Pre-requisites (third-party dependencies)

If you are working at somerengrid (our lab's private computing grid), then
all the pre-requisites are already there and you can go directly to the
installation instructions. 


### EEGLAB

[EEGLAB][eeglab] is required mostly for input/output of data from/to
 various data formats, and for plotting. Please ensure that EEGLAB is in 
your MATLAB search path.

[meegpipecfg]: http://github.com/meegpipe/meegpipe/blob/master/%2Bmeegpipe/meegpipe.ini
[ftrip]: http://fieldtrip.fcdonders.nl/
[eeglab]: http://sccn.ucsd.edu/eeglab/
[fileio]: http://fieldtrip.fcdonders.nl/development/fileio
[matlab-package]: http://www.mathworks.nl/help/matlab/matlab_oop/scoping-classes-with-packages.html

### Highly recommended dependencies

The engine responsible for generating data processing reports in HTML 
relies on several Python packages and on [Inkscape][inkscape]. _meegpipe_ will
 be fully functional without these dependencies, but the processing reports
will be generated in a plain text format (using [Remark][remark] syntax). 
Inspecting plain text reports with embedded images is _very inconvenient_
so please consider installing these [highly recommended dependencies][recommended-dep]. 

[remark]: http://kaba.hilvi.org/remark/remark.htm
[recommended-dep]: ./recommended.md
[inkscape]: http://www.inkscape.org/en/


### Optional

You are encouraged to install a few [additional components][optional] that
can enhance _meegpipe_'s functionality in terms of 
[high-throughput computing][ht-comp].


[ht-comp]: http://en.wikipedia.org/wiki/High-throughput_computing
[optional]: https://github.com/meegpipe/meegpipe/blob/master/optional.md
[gc]: http://www.google.com/chrome



## Installation

Copy and paste the following code in the MATLAB command window:

````matlab
unzip('https://github.com/meegpipe/meegpipe/zipball/master', 'meegpipe');
addpath(genpath('meegpipe'));
meegpipe.initialize;
% Initialize meegpipe every time that MATLAB starts
addpath(userpath);
fid = fopen(which('startup'), 'a');
fprintf(fid, '\n\naddpath(genpath(''%s''));\n', [pwd filesep 'meegpipe']);
fprintf(fid, 'meegpipe.initialize;\n\n');
fclose(fid);
````

Notice that the code above will install _meegpipe_ in directory `meegpipe`
under your current working directory. Notice also that EEGLAB needs to be 
part of your MATLAB search path for the `meegpipe.initialize` command to
 succeed. 


## Basic usage

### Data import

````matlab
import physioset.import.*;
% Import from an .mff file
data = import(mff, 'myfile.mff');
% Import from an EDF+ file
data = import(edfplus, 'myfile.edf');
% Import MATLAB built-in numerics
data = import(matrix, randn(10,10000));
````
All data importer classes implement an `import()` method, which always
produces a [physioset][physioset] object. For more information and a list
of available data importers see the [documentation][import-docs].


[import-docs]: https://github.com/meegpipe/meegpipe/blob/master/+physioset/+import/README.md
[physioset]: https://github.com/meegpipe/meegpipe/blob/master/+physioset/README.md



### Data processing nodes


````matlab
import meegpipe.*;
import physioset.import.matrix;

data = import(matrix, randn(10,10000));

% Detrend using a 10th order polynomial to remove very low freq. trends
myNode1 = node.filter.new('Filter', filter.polyfit('Order', 10));
run(myNode1, data);

% Reject bad channels
myNode2  = node.bad_channels.new;
run(myNode2, data);

% Apply a band pass filter between 0.1 and 70 Hz
myFilter = @(sr) filter.bpfilt('Fp', [0.1 70]/(sr/2));
myNode3   = node.filter.new('Filter', myFilter);
run(myNode3, data);

% Remove powerline noise using Blind Source Separation (BSS)
myNode4   = node.bss.pwl;
run(myNode4, data);

% Reject ocular artifacts using BSS
myNode5   = node.bss.eog;
run(myNode5, data);

% etc ...
````

For more information and a list of available processing nodes, see the
[documentation][nodes-docs].

[wiki-ref]: http://en.wikipedia.org/wiki/Reference_(computer_science)
[nodes-docs]: http://github.com/meegpipe/meegpipe/blob/master/+meegpipe/+node/README.md


### Processing reports

One of the great features of _meegpipe_ is that it generates comprehensive
HTML reports for every data processing task. In the example above, you
should have got a warning saying something like:

> <strong>Warning</strong>: A new session was created in folder 'session_1' <br>
> In session.session>session.instance at 82 <br>
>  In pset.generate_data at 35 <br>
>  In matrix.import at 62 <br>

This means that _meegpipe_ just created a directory `session_1`, which will be
used to store, among other things, the data processing reports. Namely, you can
find a node's HTML report under:

    session_1/[DATA].meegpipe/[NODE]_[USR]_[SYS]/remark/index.htm

where

__DATA__ is a string identifying the processed [physioset][physioset]. Use
 method `get_name()` to find out the name of a [physioset][physioset] object.

__NODE__ is a string identifying the _processing node_. It is a combination of
 the node name (which can be obtained using method `get_name()`) and a hash code that
 summarizes the node configuration.

__USR__ is just the name of the user that ran command `run()`.

__SYS__ is a string identifying the operating system and MATLAB version (e.g. _PCWIN64-R2011b_).


Neither Firefox nor Google Chrome are able to display local .svg files, when
running under Windows 8. Whenever trying to do so, both browsers attempt to
download the file and thus the file is not displayed. Read the
[document on known issues and limitations][issues] for ways to overcome
this problem.

[issues]: https://github.com/meegpipe/meegpipe/blob/master/issues.md


__NOTE:__ HTML reports will be generated only if you have installed all 
the [recommended dependencies][recommended-dep] on your system. 

### Pipelines

A `pipeline` is just a concatenation of nodes. With the exception of
[physioset_import][node-physioset_import] nodes, all other node classes always
take a [physioset][physioset] as input. And with the exception of
[physioset_export][node-physioset_export] nodes, all other node classes produce a
`physioset` object as output.

The five processing steps that we performed above when illustrating how nodes
work could have been grouped into a pipeline:

[node-physioset_import]: https://github.com/meegpipe/meegpipe/blob/master/%2Bmeegpipe/%2Bnode/%2Bphysioset_import/%40physioset_import/physioset_import.m
[node-physioset_export]: https://github.com/meegpipe/meegpipe/blob/master/%2Bmeegpipe/%2Bnode/%2Bphysioset_export/%40physioset_export/physioset_export.m

````matlab
import meegpipe.*;
import physioset.import.*;

myPipe = node.pipeline.new(...
    'NodeList', {myNode1, myNode2, myNode3, myNode4, myNode5})
data = run(myPipe, 'myfile.mff');

````

### Data export

````matlab
% Create a random EEG physioset for illustration purposes
mySensors  = sensors.eeg.from_template('egi256');
mySensors  = subset(mySensors, 1:10:256);
myImporter = physioset.import.matrix('Sensors', mySensors);
data = import(myImporter, randn(26, 2000));

% Export to EEGLAB
myEEGLABStr = eeglab(data);
% Export to Fieldtrip
myFTripStr = fieldtrip(data);
````


## More information

See the practical [tutorials](http://github.com/meegpipe/meegpipe/tree/master/tutorials/README.md)
for some typical use cases of _meegpipe_. A high-level description of the API components
can be found in the [documentation][doc-main], which is still work
in progress.

[doc-main]: https://github.com/meegpipe/meegpipe/blob/master/%2Bmeegpipe/README.md

## Attribution

For convenience, _meegpipe_ ships together with code from third-parties.
You can find a comprehensive list [here][attribution].

[attribution]: https://github.com/meegpipe/meegpipe/blob/master/attribution.md


## License

Any code that is not part of any of the bundled third-party dependencies
(see [the list][attribution]), is released under the
[Creative Commons Attribution-NonCommercial-ShareAlike licence](http://creativecommons.org/licenses/by-nc-sa/3.0/).
