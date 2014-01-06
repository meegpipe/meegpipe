meegpipe
========

_meegpipe_ is a collection of MATLAB tools for building advanced processing
pipelines for high density physiological recordings. It is especially 
suited for the processing of high-density [EEG][eeg] and [MEG][meg], 
but can also handle other modalities such as [ECG][ecg], temperature, 
[actigraphy][acti], light exposure, etc. 

Be aware however that, so far, _meegpipe_ has been tested only with hdEEG data, 
and even in that case the testing has been very superficial. So expect to find
many bugs if you are brave enough to use the current version. On the bright 
side, you should expect the API to be relatively stable at this point. 

At this moment, there is no stable release of _meegpipe_. The code that you
can download from here is the development version, which changes almost 
daily. This doesn't mean that the current version is not useful. But it 
means that you should have the mindset of a beta-tester and update 
regularly to the latest version. You should also subscribe to
_meegpipe_'s [google group][gg], where I will be posting information on
 major bug fixes and updates.

[gg]: https://groups.google.com/forum/#!forum/meegpipe

If you find any bug or have any feedback to share, please 
[contact me][ggh].

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


## Pre-requisites

If you are working at somerengrid (our lab's private computing grid), then all the
pre-requisites are already there and you can go directly to the installation instructions.
Otherwise, you will have to install the requirements below. 


### Fieldtrip and EEGLAB

[Fieldtrip][ftrip] and [EEGLAB][eeglab] are required mostly for input/output 
of data from/to various data formats, and for plotting. Please __do not__ add
Fieldtrip and EEGLAB to your MATLAB search path. Instead simply edit 
[+meegpipe/meegpipe.ini][meegpipecfg] to include the paths to the root 
directories of Fieldtrip and EEGLAB on your system.

[meegpipecfg]: http://github.com/germangh/meegpipe/blob/master/%2Bmeegpipe/meegpipe.ini
[ftrip]: http://fieldtrip.fcdonders.nl/
[eeglab]: http://sccn.ucsd.edu/eeglab/
[fileio]: http://fieldtrip.fcdonders.nl/development/fileio
[matlab-package]: http://www.mathworks.nl/help/matlab/matlab_oop/scoping-classes-with-packages.html

### Python

A. Kenneth Reitz has written an excellent guide on 
[how to install Python][python-install]. _meegpipe_ requires a Python 2.x
interpreter, where x is ideally at least 7. Please ensure that 
_easy\_install_ and _pip_ are also installed. Refer to the 
[python installation guide][python-install] for more details. 

[python]: http://python.org
[python-install]: http://docs.python-guide.org/en/latest/starting/installation/

If your OS is Linux-based (that includes Mac OS X) chances are that Python is already 
installed on your system. In that case, open a terminal and ensure that you have the 
required version of Python:

	python --version
	
Even if your OS ships with Python, you may have to install _easy\_install_ and _pip_. 


### Remark

The [Remark][remark] python library is required for generating HTML reports.
To install Rermark in Mac OS X and Linux run from the command line:

[remark]: http://kaba.hilvi.org/remark/remark.htm

    sudo pip install remark

In Windows, open a terminal and run:

    easy_install pillow
    pip install remark


### Inkscape

[Inkscape][inkscape] is required for generating the thumbnail images that
are embedded in the data processing reports.

[inkscape]: http://en.dev.inkscape.org/download/
[pygments]: http://pygments.org/
[markdown]: http://freewisdom.org/projects/python-markdown/
[pil]: http://www.pythonware.com/products/pil/


### Google Chrome (optional, strongly recommended)

_meegpipe_ generates HTML reports with lots of [.svg][svg] graphics
embedded. [Google Chrome][gc] is far superior to other browsers when handling
`.svg` files and thus it is strongly recommended that you install Google
Chrome. 

[svg]: http://en.wikipedia.org/wiki/Scalable_Vector_Graphics
[gc]: https://www.google.com/intl/en/chrome/browser/

__NOTE for Windows 8 users__: For some unknown reason neither Firefox nor
Google Chrome are able to display local .svg files, when running under 
Windows 8. Whenever trying to do so, both browsers attempt to download the 
file and thus the file is not displayed. Read section 
_Known problems/limitations_ at the end of this document for possible 
solutions to this problem.


### Sun/Oracle grid engine (optional)

If [Oracle Grid Engine][oge] (OGE) is installed on your system,
then _meegpipe_ should be able to use it to push your processing jobs to the
grid.  A good overview on the administration of OGE can be found on 
[this presentation][oge-slides] by Daniel Templeton. 


[oge]: http://www.oracle.com/us/products/tools/oracle-grid-engine-075549.html
[oge-install]: http://docs.oracle.com/cd/E19680-01/html/821-1541/ciajejfa.html
[oge-slides]: http://beowulf.rutgers.edu/info-user/pdf/ge_presentation.pdf


### Condor high-throughput computing (optional)

If [Condor][condor] is installed on your system then _meegpipe_ will be 
able to use to parallelize the workload produced by _meegpipe_. Condor can 
be used to submit jobs to specialized clusters, to idle computers, to 
the grid, or even to the cloud. If you are using _meegpipe_ on a powerful 
multi-core workstation you can also use Condor to exploit these local 
parallel resources. 


## Installation

Clone the repository, either in [.zip format](https://github.com/meegpipe/meegpipe/archive/master.zip)
or using the command line, as follows:

````bash
$ cd ~
$ git clone git://github.com/meegpipe/meegpipe
````

The commands above will install _meegpipe_ source code under directory
 `~/meegpipe`. 


## Basic usage

Before anything else you will have to add to your MATLAB path 
some third-party dependencies (e.g. components of [Fieldtrip][ftrip] and 
[EEGLAB][eeglab]). First edit the contents of [+meegpipe/meegpipe.ini][ini] to
include the locations of the third-party dependencies on your system. Then run
the following in MATLAB:

``````matlab
restoredefaultpath;
addpath(genpath('~/meegpipe'));
meegpipe.initialize;
````

The commands above will ensure that your MATLAB search path contains __only__ 
the third-party components that are needed for _meegpipe_ to run. 
Namely, _meegpipe_ itself, and a subset of Fieldtrip and EEGLAB. The 
`restoredefaultpath` command is important to ensure that other toolboxes do 
not interfere with _meegpipe_. On the other hand, _meegpipe_ components are 
all encapsulated in [MATLAB packages][matlab-pkg], which should prevent 
_meegpipe_ interfering with other toolboxes. Thus it should be relatively
 safe for you to add the three lines above to your MATLAB [startup][startup]
 function so that you don't need to type them every time you start MATLAB.

[startup]: http://www.mathworks.nl/help/matlab/ref/startup.html
[eeglab]: http://sccn.ucsd.edu/eeglab/
[ftrip]: http://fieldtrip.fcdonders.nl/
[ini]: http://github.com/germangh/meegpipe/blob/master/%2Bmeegpipe/meegpipe.ini
[matlab-pkg]: http://www.mathworks.nl/help/matlab/matlab_oop/scoping-classes-with-packages.html


### Data import

See `help physioset.import` for a list of available data importers.

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
produces a [physioset][physioset] object. 

[physioset]: https://github.com/germangh/matlab_physioset/blob/master/%2Bphysioset/%40physioset/physioset.m

### Data processing nodes

See `help meegpipe.node` for a list of available nodes.

````matlab
import meegpipe.*;
import physioset.import.matrix;

data = import(matrix, randn(10,10000));

% Detrend using a 10th order polynomial
myNode1 = node.detrend.new('PolyOrder', 10);
run(myNode1, data);

% Filter data using a tfilter (temporal filter) node
% First build a band-pass filter object
myFilter = filter.bpfilt('Fp', [0.1 0.3]);
% And then use it to construct the node
myNode2 = node.tfilter.new('Filter', myFilter);
run(myNode2, data);
````

Note that method `run()` takes a [reference][wiki-ref] to the input data, 
rather than _a copy of the input data_. This means that `run()` operates 
directly on the input data. Thus after running the code above, `data` 
will be __both__ detrended and filtered. 

If you wondered what is that `alias_import` about, just read the inline 
documentation of [alias_import][alias-import].

[wiki-ref]: http://en.wikipedia.org/wiki/Reference_(computer_science)
[alias-import]: https://github.com/germangh/meegpipe/blob/master/%2Bmeegpipe/alias_import.m

### Processing reports

One of the great features of _meegpipe_ is that it generates comprehensive 
HTML reports for every data processing task. In the example above, you probably
got a warning saying something like:

> <strong>Warning</strong>: A new session was created in folder 'session_1' <br>
> In session.session>session.instance at 82 <br>
>  In pset.generate_data at 35 <br>
>  In matrix.import at 62 <br>

This means that _meegpipe_ just created a directory `session_1`, which will be 
used to store, among other things, the data processing reports. Namely, you can 
find a node's HTML report under:

    session_1/[DATA].meegpipe/[NODE]_[USR]_[SYS]/remark/index.htm

where

* __DATA__ is a string identifying the processed [physioset][physioset]. Use
 method `get_name()` to find out the name of a [physioset][physioset] object.

* __NODE__ is a string identifying the _processing node_. It is a combination of 
 the node name (which can be obtained using method `get_name()`) and a hash code that 
 summarizes the node configuration. 

* __USR__ is just the name of the user that ran command `run()`.

* __SYS__ is a string identifying the operating system and MATLAB version (e.g. _PCWIN64-R2011b_). 



### Pipelines

A _pipeline_ is just a concatenation of nodes. With the exception of
[physioset_import][node-physioset_import] nodes, all other node classes always
take a [physioset][physioset] as input.

[node-physioset_import]: https://github.com/germangh/meegpipe/blob/master/%2Bmeegpipe/%2Bnode/%2Bphysioset_import/%40physioset_import/physioset_import.m

````matlab
import meegpipe.*;
import physioset.import.*;
myNode1  = node.physioset_import.new('Importer', mff);
myFilter = filter.bpfilt('Fp', [0.1 0.3]);
myNode2  = node.tfilter.new('Filter', myFilter);
myPipe   = node.pipeline.new('NodeList', {myNode1, myNode2});

% Will read from .mff file, and band-pass filter the data it contains
data = run(myPipe, 'myfile.mff');

````

### Data export

````matlab
% Create a random EEG physioset
mySensors = sensors.eeg.from_template('egi256');
mySensors = subset(mySensors, 1:10:256);
myImporter = physioset.import.matrix('Sensors', mySensors);
data = import(myImporter, randn(26, 2000));
% Export to EEGLAB
myEEGLABStr = eeglab(data);
% Export to Fieldtrip
myFTripStr = fieldtrip(data);
````

## More information

See the practical [tutorials](http://github.com/meegpipe/meegpipe/tree/master/tutorials)
for some typical use cases of _meegpipe_. A high-level description of the API components 
can be found in the [documentation][doc-main], which is still work 
in progress. 

[doc-main]: https://github.com/meegpipe/meegpipe/blob/master/%2Bmeegpipe/README.md



## Known problems/limitations


### Long path names under Windows

_meegpipe_ has a tendency to generate reports with very deep file structures.
Under Windows this might cause a problem due to the 
[maximum path length limitation][maxpath]. At this moment there is no 
failproof workaround. However, you should be able to avoid the problem
by simply using short pipeline names, and by avoiding deep nesting of 
pipelines within pipelines.


### Inkscape crashes

Under some very rare circumstances, [inkscape][inkscape] crashes when being
called from the command line in Windows 8. Such crashes typically manifest 
as a pop-up window with an error message. This problem can be solved by
using the [development version of Inkscape][inkscape-dev] (release r23126
 and above).

[maxpath]: http://msdn.microsoft.com/en-us/library/aa365247%28VS.85%29.aspx#maxpath
[inkscape-dev]: https://skydrive.live.com/?cid=09706d11303fa52a&id=9706D11303FA52A%21217#cid=09706D11303FA52A&id=9706D11303FA52A%21275


### Local `.svg` files do not render under Windows 8

Under __Windows 8__ neither Firefox nor Google Chrome are able to render 
local .svg files.  There are two possible solutions to this problem:

* Use MS Explorer under Windows 8. This is far from ideal as MS Explorer 
  is quite slow at rendering .svg files. In particular, you will experience 
  very poor performance when trying to zoom-in an image. 

* Run a local HTTP server that will serve the report page. In practice 
  this just means double clicking on the `pyserver.bat` file that you 
  will find on the root directory of each generated report. The `.bat` 
  file will use Python to start a local server at port 8000. It will also 
  try opening Chrome and point it to the server root
  URL: http://127.0.0.1:8000/ . Of course for this solution to work both 
  Python and Chrome need to be installed on your Windows 8 system. Also,
  the installation directory of Chrome must be the default under Windows 8:
  `C:\Program Files (x86)\Google\Chrome\Application\chrome.exe`.


The downside of the second solution above is that you will not be able to
display multiple reports simultaneously in Chrome. This problem can be 
overcome by editing `pyserver.bat` so that different reports are served on
different HTTP ports. 


## Attribution

For convenience, _meegpipe_ ships together with code from third-parties. 
You can find a comprehensive list [here][attribution]. 

[attribution]: https://github.com/germangh/meegpipe/blob/master/attribution.md



## License

Any code that is not part of any of the bundled third-party dependencies
(see [the list][attribution]), is released under the 
[Creative Commons Attribution-NonCommercial-ShareAlike licence](http://creativecommons.org/licenses/by-nc-sa/3.0/). 
