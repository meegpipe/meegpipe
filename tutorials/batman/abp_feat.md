ABP feature extraction
===

[Go to the previous tutorial step][splitting_raw_data]

[splitting_raw_data]: ./splitting_raw_data.md

In this third part of the tutorial we will extract several potentially
interesting features from the [Arterial Blood Pressure (ABP)][abp] time-series
that are part of the BATMAN study. For more information regarding the list of
features and the way they are computed we refer you to
[physionet's cardiac output toolbox][cotb], and to the following two publications:

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

In the code samples shown below I assume that you are running this tutorial at
the _somerengrid_ and that you have run the following two commands when you
started your MATLAB session:

````matlab
close all; clear all; clear classes;
restoredefaultpath;
addpath(genpath('/data1/toolbox/meegpipe_v1.0.0'));
meegpipe.initialize;
````

Note: You may need to change the path to `meegpipe` above, so that it matches
the most up to date version (1.0.0 at the time of writing this).

## Main processing script

Before writing our data processing pipeline we are going to write the skeleton
of our _main_ processing script where we perform the necessary preliminaries,
and where we run the pipeline (which we will write later) on the relevant data
files.

First we specify the locations of the input files to this processing stage (the
output of the previous tutorial stage), and the location where the processing
results should be stored:

````matlab
INPUT_DIR = '/data1/projects/meegpipe/batman_tut/gherrero/split_files_output'
OUTPUT_DIR = '/data1/projects/meegpipe/batman_tut/gherrero/extract_abp_features_output';
````
Note that `INPUT_DIR` above matches the output directory of the previous step of
this tutorial, where we [split the raw data files][splitting_raw_data] into
smaller files. We also use constants to specify whether full HTML reports
should be generated, and whether processing jobs should be run as parallel
background jobs.


````matlab
PARALELLIZE = true; % Should each file be processed in parallel?
DO_REPORT   = true; % Should full HTML reports be generated?
````

We now create an instance of the data processing pipeline using a helper
function (`batman.extract_abp_features_pipelines`) to take care of specifying
and building the pipeline nodes:

````matlab
myPipe = batman.extract_abp_features_pipeline(...
    'GenerateReport', DO_REPORT, ...
    'Parallelize',    PARALELLIZE);
````

Of course, we have not written any `batman.extract_abp_features_pipeline` so the
code above will not work quite yet. But it will soon enough.

The ABP features should be extracted from every split file that was produced in
the [previous section][splitting_raw_data] of this tutorial. So let's get hold
of them:


````matlab
import mperl.file.file.finddepth_regex_match;
regex = 'split_files-.+_\d+\.pset';
splittedFiles = finddepth_regex_match(INPUT_DIR, regex);
````

The code above will build a cell array of file names `splittedFiles`, by matching
a [regular expression][regex] (a _pattern_) to the names of all the files
located within directory `INPUT_DIR` and any of its sub-directories.

Regular expressions are a extremely powerful way of finding the items you want
among a very large list of strings. In this case we are looking for a set of
files within a directory tree listing that may contain thousands of items
(file names). Mastering regular expressions is far from trivial and there are
[whole books][regex-book] dedicated to the topic. I will not go into details,
but the pattern `split_files-.+_\d+\.pseth?` will __match__ any string that
contains the text `split_files`, followed by one or more characters (`.+`),
followed by an underscore, followed by one or more digits (`\d+`), followed by
the string `.pset` (`\.pset`). This pattern matches exactly the split files
that we are interested in.

[regex]: http://en.wikipedia.org/wiki/Regular_expression
[regex-book]: http://shop.oreilly.com/product/9780596528126.do

Recall that _meegpipe_ always stores processing results under the same directory
where the input file is located (under a different`.meegpipe` directory with the
same name as the input file). Thus we can't just process all the files listed in
the cell array `splittedFiles`. Well, we could, but that would mess our tidy
directory structure and store the results somewhere deep under `INPUT_DIR`.
Instead, we want the results to be stored under `OUTPUT_DIR`:

````matlab
somsds.link2files(splittedFiles, OUTPUT_DIR);
````

The command above creates symbolic links to all files listed in `splittedFiles`
and stores such links under `OUTPUT_DIR`. Now `OUTPUT_DIR` contains (links to)
all relevant data.

A final detail is that the split files are stored in _meegpipe_'s own format
`.pset/.pseth` which uses a header file (`.pseth`) and an
associated data file (`.pset`). You should only input to your pipeline the
`.pseth` files. Again we make use of regular expressions to pick the set of
files we want:

````matlab
% Pick any file under OUTPUT_DIR whose name ends (thus the $ anchor) with .pseth
regex = '\.pseth$';
files = finddepth_regex_match(OUTPUT_DIR, regex);
````

Finally:

````matlab
run(myPipe, files{:});
````


## The feature extraction pipeline

It is now time to write the crucial helper function
`extract_abp_features_pipeline`, which takes care of building an instance of the
feature extraction pipeline.


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

Disk files in `.pseth/.pset` format store a [serialized][serialization] version
of a `physioset` object. Recall from the [documentation][physioset] that
physioset objects are never copied by default, and that they behave as
references to a ([memory-mapped][memmap]) disk file. The code below illustrates
what I mean:

[serialization]: http://en.wikipedia.org/wiki/Serialization
[memmap]: http://www.mathworks.nl/help/matlab/import_export/overview-of-memory-mapping.html

````matlab
%% Note that this code snippet is just for illustration purposes. You should not
%% put this code into your extract_abp_features_pipeline function.

% Create a dummy physioset object
myPhysObj = import(physioset.import.matrix, rand(4, 1000));

% Let' save the physioset to a disk file in .pseth/.pset format and let's keep
% track of the corresponding header (.pseth) file name.
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

The code above should make clear that, if we load a physioset object from a
`pset/.pseth` file and we modify the values of the loaded physioset, then
__we will be modifying the contents of the original `.pset/.pseth` file__.
The [file splitting section][splitting_raw_data] of this tutorial can take many
hours to complete, depending on how many files you process. You obviously want
to keep the split files untouched, to prevent having to reproduced the splitting
should you have to re-run the ABP feature extraction. This can be accomplished
by including a [copy][copy] node in your pipeline to create an independent
(but identical) copy of the input physioset:

[copy]: ../../+meegpipe/+node/+copy/README.md

````matlab
% This import directive needs to be run only once. I put it here to stress the
% fact that copy.new actually means: meegpipe.node.copy.new
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
requires quite a bit of ad-hoc heuristics. See function
[calibrate_abp][calibrate_abp] if you want to learn the details.

[calibrate_abp]: ./+batman/calibrate_abp.m
[physionet]: http://physionet.org



### Node 4: Beat onset detection

A prerequisite to extracting any valuable feature from the ABP signal is to
detect the onset of each heartbeat. This can be done using an
[abp_beat_detect][abp_beat_detect] node:

[abp_beat_detect]: ../../+meegpipe/+node/+abp_beat_detect/README.md

````matlab
import meegpipe.node.*;

% The default settings will do. But we need to use an appropriate DataSelector
% so that only the ABP signal is used by this node. You don't want this node to
% start detecting heartbeats in 257 EEG signals...
myNode = abp_beat_detect.new(...
    'DataSelector',     pset.selector.sensor_label('Portapres')...
    );
````


### Node 5: ABP feature extraction

Once the beat onsets have been detected, extracting the ABP features is piece of
cake using an [abp_features][abp_features] node:

[abp_features]: ../../+meegpipe/+node/+abp_features/README.md

````matlab
import meegpipe.node.*;

% A default node will do, but don't forget to use an appropriate DataSelector
myNode = abp_features.new(...
    'DataSelector',     pset.selector.sensor_label('Portapres') ...
    );
````

### Create the pipeline

````matlab
myPipe = pipeline.new(...
    'Name',             'batman-abp', ...
    'NodeList',         nodeList, ...
    'Save',             false);
````

Note that we set property `Save` of our pipeline to `false` to prevent saving to
disk a copy of the processed data files. This makes sense because we are
interested only in the extracted features, which are stored in separate text
files and are not part of the output physioset object. Inspect the generated
HTML reports for the detailed location of such text files.


### Putting it all together

Take a look at [batman.extract_abp_features](./+batman/extract_abp_features.m)
and
[batman.extract_abp_features_pipeline](./+batman/extract_abp_features_pipeline.m)
to see the results of the step-by-step procedure described above. To
extract the ABP features from all relevant files simply run:

````matlab
% I assume you have wrapped your files in a package called batman
batman.extract_abp_features
````

## Aggregating features across single-block files

We now have a large number of `.meegpipe` directories that contain the ABP
features (in text format) for each experimental sub-block. Having all those
features spread across such a large number of text files is inconvenient for
futher analyses using statistical software such as [R][r]. It would be much
better if we could have all ABP features in a single comma-separated file. When
pulling all features into a single file, we need to keep track whether a feature
came from this or that experimental sub-block, or this or that subject. It would
be also desirable to incorporate into our feature table information regarding
the experimental manipulation (the __condition__) that took place in a given
sub-block.

Let's start by writing a function that will translate block numbers and subject
IDs to condition names:

[r]: http://www.r-project.org/

````matlab
function [condID, condName] = block2condition(subj, blockID)
% BLOCK2CONDITION - Convert subject ID + block ID into a condition ID/name

% ...
% Ad-hoc stuff specific to the protocol that was used in the BATMAN study
% ...

end
````
If you want to know the implementation details, see
[block2condition.m][block2condition].

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
an input file name into a set of meta-info tags that identify uniquely the
corresponding experimental sub-block, and that may be useful for grouping
purposes in subsequent statistical analyses. The following function will perform
such a translation for us:

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
feature table. Below you can see how the top of that features table looks
like for me:

[abp_features_csv]: ./abp_features.csv

filename                    | subject | sub_block| block_1_14| cond_id             | cond_name            | selector               | systolic_bp | diastolic_bp | pulse_pressure | mean_pressure | mean_dyneg  | area_under_systole1 | area_under_systole2 | heart_rate | co
--------------------------  | ------- | -------- | --------- | ------------------- | -------------------- | ---------------------- | ----------- | ------------ | -------------- | ------------- | ----------- | ------------------- | ------------------- | ---------- | --------
batman_0007_eeg_all_arsq_1  | 0007    | arsq     | 1         | cond3               | light0_posture1_dpg2 | pset.selector.all_data | 98.5089     | 71.9754      | 26.5225        | 79.5602       | -0.4426     | 4.4450              | 4.5263              | 65.4675    | 10.1739
batman_0007_eeg_all_arsq_11 | 0007    | arsq     | 11        | cond9               | light0_posture1_dpg0 | pset.selector.all_data | 96.7132     | 73.8370      | 22.8633        | 79.9444       | -0.3588     | 3.8429              | 3.9264              | 66.7786    | 8.9266
batman_0007_eeg_all_arsq_12 | 0007    | arsq     | 12        | cond6               | light1_posture1_dpg1 | pset.selector.all_data | 97.0860     | 72.6804      | 24.4148        | 79.7420       | -0.3859     | 4.3479              | 4.4589              | 65.5946    | 9.3898
batman_0007_eeg_all_arsq_13 | 0007    | arsq     | 13        | cond8               | light1_posture0_dpg1 | pset.selector.all_data | 98.4168     | 72.4243      | 25.9907        | 79.6494       | -0.3081     | 5.1062              | 5.4009              | 52.7616    | 8.0201


## [Continue to the next part ...][hrv]

[hrv]: ./hrv_feat.md
