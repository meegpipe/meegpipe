% stage 2
%
% Removing ocular components and interpolating bad channels

meegpipe.initialize;

import meegpipe.node.*;
import misc.regexpi_dir;
import mperl.file.spec.catdir;
import mperl.file.find.finddepth_regex_match;
import mperl.join;
import somsds.link2files;
import misc.get_hostname;

%% Analysis parameters

DO_REPORT = false;

PIPE_NAME = 'stage2';

% The directory where the output from stage 1 can be found
INPUT_DIR = '/Volumes/DATA/tutorial_mike/stage1';

% The directory where the results of this stage will be stored
OUTPUT_DIR = '/Volumes/DATA/tutorial_mike/stage2';


%% Build pipeline nodes one by one

% Node: data import
myImporter = physioset.import.physioset;
thisNode = physioset_import.new('Importer', myImporter);
nodeList = {thisNode};

% Note: copy the physioset. Otherwise, the input file will be modified!
thisNode = copy.new;
nodeList = [nodeList {thisNode}];

% Node: Remove ocular artifacts
% We use a more conservative rejection policy
myCrit = spt.criterion.psd_ratio.eog( ...
    'Max',      30, ...
    'MaxCard',  6);
thisNode = bss_regr.eog('Criterion', myCrit);
nodeList = [nodeList {thisNode}];

% Node: Channel interpolation
thisNode = chan_interp.new;
nodeList = [nodeList {thisNode}];

% The actual pipeline
myPipe = pipeline.new(...
    'NodeList',         nodeList, ...
    'Save',             true,  ...
    'GenerateReport',   DO_REPORT, ...
    'Name',             PIPE_NAME);

%% Process all the relevant data files
regex = '_stage1\.pseth?$';
files = finddepth_regex_match(INPUT_DIR, regex);
% link2files works only under Mac OS X and Linux
link2files(files, OUTPUT_DIR);
regex = '_stage1\.pseth$';
files = finddepth_regex_match(OUTPUT_DIR, regex);

data = run(myPipe, files{:});