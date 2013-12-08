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

At this point you are ready to extract the ABP features from all relevant files
by running:

````matlab
batman.extract_abp_features
````

## Aggregating features across single-block files

We now have a large number of `.meegpipe` directories that contain the ABP
features (in text format) for each experimental sub-block. Having all those
features spread across such a large number of text files is inconvenient for
futher analyses using statistical software such as [R][r]. It would be much
better if we could have all ABP features in a single comma-separated file. At
the same time, need to keep track whether a feature came from this or that
experimental sub-block. Also, it would be very advantageous if we could
incorporate into our feature table information regarding the experimental
manipulation that took place in a given sub-block. Let's go step by step and
start by writing a function that will translate block numbers and subject IDs to
condition names:

[r]: http://www.r-project.org/

````matlab
function [condID, condName] = block2condition(subj, blockID)
% BLOCK2CONDITION - Convert subject ID + block ID into a condition ID/name

% ...
% Ad-hoc stuff specific to the protocol that was used in the BATMAN study
% ...

end
````
If you want to know the implementation details, see function
[block2condition][block2condition].

[block2condition]: ./+batman/block2condition.m

Given a subject ID and a block number we now know how to convert that
information into an informative condition name. E.g. block 1 for subject 3
corresponds to condition `light0_posture1_dpg2`:

````matlab
>> [condID, condName]=batman.block2condition(3, 1)

condID =

cond3


condName =

light0_posture1_dpg2
````

But to simplify the feature aggregation process what we need is to convert from
an input file name (e.g. `batman_0007_eeg_all_pvt_1.pseth`) into a set of
meta-info tags that identify uniquely the corresponding experimental sub-block,
and that may be useful for grouping purposes in subsequent statistical analyses.
The following function will perform such a translation for us:

````matlab
function meta = fname2meta(fName)
% FNAME2META - Translate file names into meta-information tags

import batman.block2condition;

regex = 'batman_(?<subject>\d+)_eeg_all.*_(?<sub_block>[^_]+)_(?<block_1_14>\d+)';

meta = regexp(fName, regex, 'names');

meta.subject = meta.subject;

[condID, condName] = block2condition(str2double(meta.subject), ...
    str2double(meta.block_1_14));

meta.cond_id   = condID;
meta.cond_name = condName;

end
````

Let's see how it works:

````matlab
>> batman.fname2meta('batman_0007_eeg_all_pvt_1.pseth')

ans =

       subject: '0007'
     sub_block: 'pvt'
    block_1_14: '1'
       cond_id: 'cond3'
     cond_name: 'light0_posture1_dpg2'
````

Now we have all the pieces we need to easily aggregate all feature files into
a single table:


````matlab
function aggregate_abp_features
% AGGREGATE_ABP_FEATURES - Aggregate all ABP features in a single .csv table

% Some utilities that we use below
import meegpipe.aggregate2;
import misc.dir;
import mperl.file.spec.catfile;

% The directory where the .meegpipe directories are located
OUTPUT_DIR = '/data1/projects/meegpipe/batman_tut/gherrero/extract_abp_features_output';

% This is the function that we use to translate file names into meta-info tags
FILENAME_TRANS = @batman.fname2meta;

% We need to build a cell array with the names of all .pseth files that were
% used as input to the feature extraction pipeline
regex = 'batman_0+\d+_eeg_all_.+_\d+\.pseth$';
files = dir(OUTPUT_DIR, regex);
files = catfile(OUTPUT_DIR, files);

% A pattern that matches the feature text files within the .meegpipe dirs
FEAT_FILE_REGEX = 'batman-abp-.+features.txt$';

% The name of the .csv file where the joint feature table will be stored
outputFile = catfile(OUTPUT_DIR, 'abp_features.csv');

aggregate2(files, FEAT_FILE_REGEX, outputFile, FILENAME_TRANS);

end
````

To perform the aggregation run:

````matlab
batman.aggregate_abp_features
````
which will store in file [abp_features.csv][abp_features_csv] the aggregated
feature table. Below you can see a synopsis of how the features table looks
like:

[abp_features_csv]: ./abp_features.csv

filename                    | subject | sub_block| block_1_14| cond_id             | cond_name            | selector               | systolic_bp | diastolic_bp | pulse_pressure | mean_pressure | mean_dyneg  | area_under_systole1 | area_under_systole2 | heart_rate | co
--------------------------  | ------- | -------- | --------- | ------------------- | -------------------- | ---------------------- | ----------- | ------------ | -------------- | ------------- | ----------- | ------------------- | ------------------- | ---------- | --------
batman_0007_eeg_all_arsq_1  | 0007    | arsq     | 1         | cond3               | light0_posture1_dpg2 | pset.selector.all_data | 98.5089     | 71.9754      | 26.5225        | 79.5602       | -0.4426     | 4.4450              | 4.5263              | 65.4675    | 10.1739
batman_0007_eeg_all_arsq_11 | 0007    | arsq     | 11        | cond9               | light0_posture1_dpg0 | pset.selector.all_data | 96.7132     | 73.8370      | 22.8633        | 79.9444       | -0.3588     | 3.8429              | 3.9264              | 66.7786    | 8.9266
batman_0007_eeg_all_arsq_12 | 0007    | arsq     | 12        | cond6               | light1_posture1_dpg1 | pset.selector.all_data | 97.0860     | 72.6804      | 24.4148        | 79.7420       | -0.3859     | 4.3479              | 4.4589              | 65.5946    | 9.3898
batman_0007_eeg_all_arsq_13 | 0007    | arsq     | 13        | cond8               | light1_posture0_dpg1 | pset.selector.all_data | 98.4168     | 72.4243      | 25.9907        | 79.6494       | -0.3081     | 5.1062              | 5.4009              | 52.7616    | 8.0201




## [Continue to the next part ...][hrv]

The link above is broken because the part of this tutorial is still under
preparation.

[hrv]: ./hrv_feat.md
