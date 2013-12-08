ABP feature extraction
===

In this third part of the tutorial we will extract several interesting features
from the [Arterial Blood Pressure (ABP)][abp] time-series that are part of the
BATMAN study. For more information regarding the list of features and the way
they are computed we refer you to [physionet's cardiac output toolbox][cotb],
and to the following two publications:

* Sun JX, [Cardiac Output Estimation using Arterial Blood Pressure Waveforms][pub1],
MEng Thesis, Cambridge (MA), Massachussetts Institute of Technology, Department
of Electrical Engineering and Computer Science, 2006.

* Sun JX, Reisner AT, Saeed M, Mark RG. [Estimating Cardiac Output from Arterial
Blood Pressure Waveforms: a Critical Evaluation using the MIMIC II
Database][pub2]. Computers in Cardiology 32: 295-298, 2005.

[pub1]: http://physionet.org/physiotools/cardiac-output/doc/CO-from-ABP.pdf
[pub2]: http://physionet.org/physiotools/cardiac-output/doc/s54-5.pdf
[cotb]: http://physionet.org/physiotools/cardiac-output/
[abp]: http://en.wikipedia.org/wiki/Blood_pressure

In the code samples shown below I assume that your MATLAB search is set to
its default value. You can ensure that this is the case by executing the
following command when you start MATLAB:

````matlab
restoredefaultpath;
````

## Main processing script

Before writing our data processing pipeline we are going to write the scheleton
of our _main_ processing script where we perform the necessary preliminaries,
and where we run the pipeline (which we will write later) on the relevant data
files. Below you can see a profusely commented example of how such a
[extract_abp_features.m][extract_abp_features_m] script may look like:

[extract_abp_features_m]: ./extract_abp_features.m


````matlab
% EXTRACT_ABP_FEATURES - Extract ABP features from BATMAN data

% Start in a completely clean state
close all;
clear all;
clear classes;

% Add meegpipe to your path, and initialize it
addpath(genpath('/data1/toolbox/meegpipe_v0.0.8'));
meegpipe.initialize;

% Import some utilities
import mperl.file.find.finddepth_regex_match;

% The directory where the split data files are located
INPUT_DIR = '/data1/projects/meegpipe/batman_tut/gherrero/split_files_output'

% The output directory where we want to store the features and the HTML reports
OUTPUT_DIR = '/data1/projects/meegpipe/batman_tut/gherrero/extract_abp_features_output';

% Some (optional) parameters that you may want to play with when experimenting
% with your processing pipeline
PARALELLIZE = true; % Should each file be processed in parallel?
DO_REPORT   = true; % Should full HTML reports be generated?

% Create an instance of the feature extraction pipeline
myPipe = batman.extract_abp_features_pipeline(...
    'GenerateReport', DO_REPORT, ...
    'Parallelize',    PARALELLIZE);

% Note that we have not yet written function extract_abp_features_pipeline!

% Generate links to the relevant data files into the output directory. This
% step is equivalent to copying the relevant data files into the output
% directory but has the advantage of saving valuable disk space.
regex = 'split_files-.+_\d+\.pseth?';
splittedFiles = finddepth_regex_match(INPUT_DIR, regex, false);
somsds.link2files(splittedFiles, OUTPUT_DIR);
regex = '\.pseth$';
files = finddepth_regex_match(OUTPUT_DIR, regex);

% files should now be a cell array containing the full paths to the single
% sub-block .pseth files that were generated in the data splitting stage.

run(myPipe, files{:});
````



## The feature extraction pipeline

In this section we will write function `extract_abp_features_pipeline`, which is
used by script `extract_abp_features` above to process every split data file
that was produced in [the previous part][splitting] of this tutorial.

[splitting]: ./spliting_raw_data.md


### Node 1: Import the `.pseth/.pset` files

As always, the first node in our pipeline must convert the pipeline input
(typically, a file name) into a [physioset][physioset] object. In the previous
part of this tutorial, we [split the raw `.mff` data files][splitting] into
single sub-block files in meegpipe's own `.pset/pseth` format. The fact that the
input files are in a different data format implies that we need to use
a different `Importer` in our [physioset_import][physioset_import] node:

[physioset_import]: ../../+meegpipe/+node/+physioset_import/README.md
[physioset]: ../../+physioset/@physioset/README.md
[splitting]: ./splitting_raw_data.md

````matlab
% This importer object is able to import files in .pseth/.pset format
myImporter = physioset.import.physioset;

% Create an instance of a physioset_import node. This will become the first node
% in our feature extraction pipeline.
myNode = physioset_import.new('Importer', myImpoter);
````

### Node 2: Copy the input data

Disk files in `.pseth/.pset` format store a seralized version of a `physioset`
object. Recall from the [documentation][physioset] that physioset objects are
never copied by default, and that they behave as references to a
([memory-mapped][memmap]) disk file, i.e.:

[memmap]: http://www.mathworks.nl/help/matlab/import_export/overview-of-memory-mapping.html

````matlab
% Create a dummy physioset object
myPhysObj = import(physioset.import.matrix, rand(4, 1000));

% Let' save the physioset to a disk file in .pseth/.pset format and let's keep
% track of the file name.
save(myPhysObj);
fileName = get_hdrfile(myPhysObj);

% Create a new reference to the SAME physioset (not a copy!)
myPhysObj2 = myPhysObj;

% See that myPhysObj and myPhysObj2 are just two names (or aliases) for the same
% underlying physioset
myPhysObj2(1,:) = 0;
assert(all(myPhysObj(1,:) == 0));

% Let's clear all references to the physioset re-load it from the .pseth file
clear myPhysObj myPhysObj2;
myPhysObjReloaded = pset.load(fileName);

% See that the .pseth/.pset file was modified when we set the first channel to
% zeros above:
assert(all(myPhysObjReloaded(1,:) == 0));
````

The code above aims to illustrate that if we load a physioset object from a
`pset/.pseth` file and we modify the values of the loaded physioset, then
__we will be modifying the contents of the original `.pset/.pseth` file__. We
want to prevent this from happening and thus the second node of our pipeline is
going to be a [copy][copy] node, which creates a completely independent
(but identical) copy of the input physioset:

[copy]: ../../+meegpipe/+node/+copy/README.md

````
import meegpipe.node.*;

myNode = copy.new;
````


### Node 3: Calibrate the ABP signal

The [cardiac output toolbox][cotb] from [Physionet.org][physionet] requires that
the ABP signals are measured in mmHg. The calibration process can be implemented
by writing a function that transforms the input time-series accordingly:

````matlab
function calibAbpChannel = calibrate_abp(abpChannel)
% CALIBRATE_ABP - Calibrates ABP signal so that it is in mmHg units

% ...
% Do whatever is necessary to abpChannel so that calibAbpChannel is in mmHg
% ...

end
````
Once you have written such a calibration function you can use an
[operator][operator] node to incorporate it into your analysis pipeline:

[operator]: ../../+meegpipe/+node/+operator/README.md

````matlab
import meegpipe.node.*;

myNode = operator.new(...
    'DataSelector',     pset.selector.sensor_label('Portapres'), ...
    'Operator',         @batman.calibrate_abp, ...
    'Name',             'ABP calibration' ...
    );
````

Unfortunately, converting the ABP measurements in the BATMAN study to mmHg
requires quite a bit of ad-hoc (potentially inaccurate) heuristics. See function
[calibrate_abp][calibrate_abp] if you want to learn the details.

[calibrate_abp]: ./+batman/calibrate_abp.m
[physionet]: http://physionet.org



### Node 4: Beat onset detection

A preliminary step to extracting any valuable feature from the ABP signal is to
detect the onset of each heartbeat. This can be done using an
[abp_beat_detect][abp_beat_detect] node:

[abp_beat_detect]: ../../+meegpipe/+node/+abp_beat_detect/README.md

````matlab
import meegpipe.node.*;

% The default settings will do. But we need to use an appropriate DataSelector
% so that only the ABP signal is used by this node.
myNode = abp_beat_detect.new(...
    'DataSelector',     pset.selector.sensor_label('Portapres')...
    );
````


### Node 5: ABP feature extraction

Once the beat onsets have been detected, extracting the ABP features is piece of
cake using an [abp_features][abp_features] node:

````matlab
import meegpipe.node.*;

% A default node will do, but with an appropriate DataSelector
myNode = abp_features.new(...
    'DataSelector',     pset.selector.sensor_label('Portapres') ...
    );
````


### Putting it all together

Below the contents of function [extract_abp_features_pipeline.m][extract_abp_features_pipeline],
which create the pipeline that we need to extract the ABP features:

[extract_abp_features_pipeline]: ./+batman/extract_abp_features_pipeline.m

````matlab
function myPipe = extract_abp_features_pipeline(varargin)
% EXTRACT_ABP_FEATURES_PIPELINE - ABP feature extraction pipeline
%
% See also: batman

import meegpipe.node.*;
import physioset.event.class_selector;
import pset.selector.sensor_label;

% Initialize the list of nodes that the pipeline will contain
nodeList = {};

%% Node 1: data import
myImporter = physioset.import.physioset('Precision', 'double');
myNode = physioset_import.new('Importer', myImporter);
nodeList = [nodeList {myNode}];

%% Node 2: copy input physioset to prevent modifying the input .pseth files
myNode = copy.new;
nodeList = [nodeList {myNode}];

%% Node 3: Calibrate the ABP channel
myNode = operator.new(...
    'Operator',         @(x) batman.abp.calibrate_abp(x), ...
    'DataSelector',     pset.selector.sensor_label('Portapres'), ...
    'Name',             'abp-calib');
nodeList = [nodeList {myNode}];

%% Node 4: ABP onset detection
myNode = abp_beat_detect.new(...
    'DataSelector',     pset.selector.sensor_label('Portapres')...
    );
nodeList = [nodeList {myNode}];


%% Node 5: Extract ABP features
myNode = abp_features.new(...
    'DataSelector',     pset.selector.sensor_label('Portapres') ...
    );
nodeList = [nodeList {myNode}];

%% Create the pipeline
% Note that we set property Save to false because we are not interested in
% the actual physioset data values but only on the features that are
% extracted from the ABP time-series. The latter are stored in the
% generated HTML reports and thus we don't need to save a binary copy of
% the physioset that comes at the output of our pipeline.
myPipe = pipeline.new(...
    'Name',             'batman-abp', ...
    'NodeList',         nodeList, ...
    'Save',             false, ...
    varargin{:});

end
````

## Aggregating features across single-block files

## [Continue to the next step ...][hrv]

The link above is broken because the next step is still under preparation.

[hrv]: ./hrv_feat.md
