% main tutorial file

meegpipe.initialize;

import meegpipe.node.*;
import misc.regexpi_dir;
import misc.get_hostname;

%% Analysis parameters

DO_REPORT = true;

switch lower(get_hostname)
    case 'nin271'
        DATA_DIR = 'C:\Users\gomez\Dropbox\datasets';
    case 'outolintulan'
        DATA_DIR = '/Volumes/DATA/Dropbox/datasets';
    otherwise
        error('I don''t know where the data is in this system');
end

FILES_REGEX = '\.mff$';

PIPE_NAME = 'mike_tutorial';

%% Build pipeline nodes one by one

% Node: data import
myImporter = physioset.import.mff('Precision', 'double');
thisNode = physioset_import.new('Importer', myImporter);
nodeList = {thisNode};

% Node: remove very low frequency trends
thisNode = tfilter.detrend;
nodeList = [nodeList {thisNode}];

% Node: band-pass filtering
myFilter = filter.bpfilt('fp', [2 70]/(250/2));
thisNode = tfilter.new('Filter', myFilter);
nodeList = [nodeList {thisNode}];

% Node: reject bad channels using variance
minVar = @(x) median(x)-10;
maxVar = @(x) median(x) + 20*mad(x);
myCrit = bad_channels.criterion.var.new('Min', minVar, 'Max', maxVar, ...
    'NN', 10, 'Percentile', [0 99]);
thisNode = bad_channels.new('Criterion', myCrit);
nodeList = [nodeList {thisNode}];

% Node: reject bad channels using cross-correlation
minCorr = @(x) median(x) - 6;
maxCorr = @(x) median(x) + 20*mad(x);
myCrit =  bad_channels.criterion.xcorr.new('Min', minCorr, 'Max', maxCorr, ...
    'NN', 10, 'Percentile', [1 100]);
thisNode = bad_channels.new('Criterion', myCrit);
nodeList = [nodeList {thisNode}];

% Node: downsample
thisNode = resample.new('OutputRate', 250);
nodeList = [nodeList {thisNode}];

% Node: Remove powerline noise (if any)
thisNode = bss_regr.pwl;
nodeList = [nodeList {thisNode}];

% Node 5: Remove cardiac artifacts (if any)
thisNode = bss_regr.ecg;
nodeList = [nodeList {thisNode}];

% Node 6: Remove ocular artifacts
thisNode = bss_regr.eog;
nodeList = [nodeList {thisNode}];



%% The actual pipeline
myPipe = pipeline.new(...
    'NodeList',         nodeList, ...
    'Save',             true,  ...
    'GenerateReport',   DO_REPORT, ...
    'Name',             PIPE_NAME);


%% Process all relevant data files

files = regexpi_dir(DATA_DIR, FILES_REGEX);


data = run(myPipe, files{:});
