% stage1
%
% Dentrend and high-pass filter individual data files


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

PIPE_NAME = 'ssmd_auob';

SUBJECT = 149;

USE_OGE = false;

% The directory where the results will be stored
switch lower(get_hostname)
    
    case 'somerenserver'
        OUTPUT_DIR = catdir('/data1/projects/ssmd-erp/analysis', ...
            ['main_' datestr(now, 'yymmddHHMMSS')]);
        
    otherwise
        error('No idea where the data is in this system');
        
end

%% Build the pipeline nodes one by one

% Node: Merge the two blocks
myImporter = physioset.import.mff('Precision', 'double');
thisNode = merge.new('Importer', myImporter);
nodeList = {thisNode};

% % Node: detrend
% mySel = sensor_class('Class', 'EEG');
% thisNode = tfilter.detrend('DataSelector', mySel);
% nodeList = [nodeList {thisNode}];

% % Node: High-pass filter
% myFilter = @(sr) filter.hpfilt('fc', 0.5/(sr/2));
% mySel = sensor_class('Class', 'EEG');
% thisNode = tfilter.new('Filter', myFilter, 'DataSelector', mySel);
% nodeList = [nodeList {thisNode}];

% Node: band-pass filtering
mySel = sensor_class('Class', 'EEG');
myFilter = @(sr) filter.bpfilt('fp', [0.3 40]/(sr/2));
thisNode = tfilter.new('Filter', myFilter, 'DataSelector', mySel);
nodeList = [nodeList {thisNode}];

% % Node: reject bad epochs
% evSelector = class_selector('Type', 'stm+');
% mySel = sensor_label({'EEG 90', 'EEG 101'});
% myCrit = bad_epochs.criterion.stat.new(...
%     'Statistic1', @(x) max(abs(x)), ...
%     'Statistic2', @(x) max(x), ...
%     'Max',        200);
% thisNode = bad_epochs.new(...
%     'EventSelector', evSelector, ...
%     'Criterion',     myCrit, ...
%     'DataSelector',  mySel);

% Node: Re-reference to mastoids
thisNode = reref.linked('EEG 190', 'EEG 94');
nodeList = [nodeList {thisNode}];

% Node: Compute ERP
evSelector = ssmd_auob.cel_selector(1);
thisNode = erp.new(...
    'EventSelector',    evSelector, ...
    'Duration',         1.2, ...
    'Offset',           -0.2, ...
    'Baseline',         [-0.2 0], ...
    'PeakLatRange',     [0.3 0.6], ...
    'AvgWindow',        0.05, ...
    'MinMax',           'max', ...
    'Channels',         {'EEG 90', 'EEG 101'}, ...
    'Name',             'erp-cel-1');
nodeList = [nodeList {thisNode}];

% Node: Compute ERP
evSelector = ssmd_auob.cel_selector(2);
thisNode = erp.new(...
    'EventSelector',    evSelector, ...
    'Duration',         1.2, ...
    'Offset',           -0.2, ...
    'Baseline',         [-0.2 0], ...
    'PeakLatRange',     [0.3 0.6], ...
    'AvgWindow',        0.05, ...
    'MinMax',           'max', ...
    'Channels',         {'EEG 90', 'EEG 101'}, ...
    'Name',             'erp-cel-2');
nodeList = [nodeList {thisNode}];

% The actual pipeline
myPipe = pipeline.new(...
    'NodeList',         nodeList, ...
    'Save',             true,  ...
    'GenerateReport',   DO_REPORT, ...
    'Name',             PIPE_NAME, ...
    'OGE',              USE_OGE);


%% Process all relevant data files
allFiles = {};

for i = 1:numel(SUBJECT)
    switch lower(get_hostname)
        
        case 'somerenserver'
            files = link2rec('ssmd', ...
                'modality',     'eeg', ...
                'condition',    'auob', ...
                'subject',      SUBJECT(i), ...
                'file_ext',     '.mff', ...
                'Folder',       OUTPUT_DIR);
            
        otherwise
            error('I don''t know where the data files are in this system');
    end
    
    if isempty(files),
        warning('ssmd_auob:NoFiles', ...
            'No files found for subject %d', SUBJECT(i));
    end
    
    allFiles = [allFiles;files]; %#ok<*AGROW>
    
end


data = run(myPipe, allFiles);
