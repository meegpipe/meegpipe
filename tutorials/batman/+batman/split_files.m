% SPLIT_FILES - Split BATMAN's large .mff files into single-block files
%
% This is the first stage of the BATMAN processing chain. The input to this
% stage are the raw .mff files. The produced output is a set of
% single-block .pset/pseth files (meegpipe's own data format). By
% single-block we mean a single condition block (Baseline, PVT, RS, RSQ)
% within a given experimental manipulation.


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

% Create an instance of your data splitting pipeline
myPipe = batman.split_files_pipeline(...
    'GenerateReport', DO_REPORT, ...
    'Parallelize',    PARALELLIZE);

% Note that we have not yet written function splitting_pipeline!

% Generate links to the relevant data files into the output directory. This
% step is equivalent to copying the relevant data files into the output
% directory but has the advantage of saving valuable disk space. The
% command below will only work at somerengrid. 
files = somsds.link2rec('batman', 'subject', [1 2], 'folder', OUTPUT_DIR);

% files should now be a cell array containing the full paths to the files
% that are to be splitted (or, rather, the full paths to the symbolic links
% that point to those files).

% This is kind of obvious...
run(myPipe, files{:});
