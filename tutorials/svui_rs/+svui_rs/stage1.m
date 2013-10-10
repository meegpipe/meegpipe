% stage1
%
% Basic pre-processing: detrending, resampling, hp-filtering, etc


meegpipe.initialize;

import meegpipe.node.*;

import misc.regexpi_dir;
import mperl.file.spec.catdir;
import mperl.file.find.finddepth_regex_match;
import mperl.join;
import somsds.link2files;
import misc.get_hostname;
import physioset.event.class_selector;
import somsds.link2rec;
import pset.selector.sensor_class;

%% Analysis parameters

DO_REPORT = true;

PIPE_NAME = 'stage1';

SUBJECT = 1:100;

USE_OGE = true;

% The directory where the results will be stored
OUTPUT_DIR = '/data1/projects/svui/analysis/stage1';


%% Build the pipeline nodes one by one

%%% Node: read data from disk
myImporter = physioset.import.fileio('Precision', 'double');
thisNode = physioset_import.new('Importer', myImporter);
nodeList = {thisNode};

%%% Node: center
thisNode = center.new;
nodeList = [nodeList {thisNode}];

%%% Node: detrend
mySel = sensor_class('Class', 'EEG');
thisNode = tfilter.detrend('DataSelector', mySel);
nodeList = [nodeList {thisNode}];

%%% Node: resample
myNode = resample.new('OutputRate', 250);
nodeList = [nodeList {thisNode}];

%%% Node: High-pass filter
myFilter = @(sr) filter.hpfilt('fc', 0.5/(sr/2));
mySel = sensor_class('Class', 'EEG');

% note that we use a data selector to indicate that only the EEG data 
% should be filtered by the node (e.g. the ECG lead should be ignored)
thisNode = tfilter.new('Filter', myFilter, 'DataSelector', mySel);
nodeList = [nodeList {thisNode}];

%%% Node: bad channels rejection
thisNode = bad_channels.new;
nodeList = [nodeList {thisNode}];

%%% Node: bad samples rejection
thisNode = bad_samples.new;
nodeList = [nodeList {thisNode}];

% The actual pipeline
myPipe = pipeline.new(...
    'NodeList',         nodeList, ...
    'Save',             true,  ...
    'GenerateReport',   DO_REPORT, ...
    'Name',             PIPE_NAME, ...
    'OGE',              USE_OGE);


%% Process all relevant data files
files = link2rec('svui', ...
    'modality',     'eeg', ...
    'cond_regex',    'rs-', ...
    'subject',      SUBJECT, ...
    'file_ext',     '.raw', ...
    'Folder',       OUTPUT_DIR);

data = run(myPipe, files{:});
