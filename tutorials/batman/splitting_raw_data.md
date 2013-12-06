Splitting raw data files
===

The raw data files that we just [linked to in the previous step][getting_raw]
of this tutorial are very large: about 30 GB each. It is certainly possible to
use `meegpipe` to work with such large files directly, but it is generally
a good idea to try to work with smaller chunks of your data at a time, if that
makes sense for your particular analysis. Otherwise, you may need to wait a long
for every processing stage to complete on a given file.

In this tutorial we want to extract features for each experimental condition
separately. Thus, it makes sense to split our original data files into 12
single-block files, each containing just one experimental manipulation.
`meegpipe` allows you to process files into parallel jobs and thus breaking
your files into 12 smaller chunks has the potential of reducing computation
times considerably.


[getting_raw]: ./getting_raw_data.md


## Keeping your scripts organized

We are going to wrap all the scripts necessary to perform the file splitting
into a MATLAB package called `batman.split_files`. Open MATLAB and type:

````matlab
cd /data1/projects/meegpipe/batman_tut/gherrero
mkdir +batman
mkdir +batman/+split_files
````

From now on we will save all scripts under `+batman/+split_files`.


## Main processing script

Before writing our data processing pipeline we are going to write the scheleton
of our _main_ processing script where we perform the necessary preliminaries,
and where we run the pipeline (which we will write later) on the relevant data
files. Below you can see a profusely commented example of how such a `main.m`
script may look like:

````matlab
% Start in a completely clean state
close all;
clear all;
clear classes;
restoredefaultpath;

% Add meegpipe to your path, and initialize it
addpath(genpath('/data1/toolbox/meegpipe_v0.0.8'));
meegpipe.initialize;

% The output directory where we want to store the splitted data files
OUTPUT_DIR = '/data1/projects/meegpipe/batman_tut/gherrero/split_files_output';

% Some (optional) parameters that you may want to play with when experimenting
% with your processing pipeline
PARALELLIZE = true; % Should each file be processed in parallel?
DO_REPORT   = true; % Should full HTML reports be generated?

% Generate links to the relevant data files into the output directory. This
% step is equivalent to copying the relevant data files into the output
% directory but has the advantage of not duplicating the data files.
files = somsds.link2rec('batman', 'subject', [1 2], 'folder', OUTPUT_DIR);

% Create an instance of your data splitting pipeline
myPipe = batman.split_files.splitting_pipeline(...
    'GenerateReport', DO_REPORT, ...
    'Parallelize',    PARALELLIZE);

% Note that we have not yet written function splitting_pipeline!

% Run the pipeline on the relevant data files
run(myPipe, files{:});

````
