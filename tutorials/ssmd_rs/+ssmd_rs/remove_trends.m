function split_files
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

meegpipe.initialize;

% Import some miscellaneous utilities
import misc.dir;
import mperl.file.spec.catfile;
import misc.get_hostname;

% The output directory where we want to store the splitted data files
switch lower(get_hostname),
    case {'somerenserver', 'nin389'}
        OUTPUT_DIR = '/data1/projects/meegpipe/batman_tut/gherrero/split_files_output';
    otherwise,
        OUTPUT_DIR = '/Volumes/DATA/tutorial/batman/split_files_output';
end

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
switch lower(get_hostname),
    case {'somerenserver', 'nin389'}
        files = somsds.link2rec(...
            'batman', ...           % The recording ID
            'subject', [1 2], ...   % The subject ID(s)
            'modality', 'eeg', ...  % The data modality
            'folder',  OUTPUT_DIR); % The directory where the links will be generated
        
    case 'outolintulan',
        DATA_DIR = '/Volumes/DATA/datasets/batman';
        files = catfile(DATA_DIR, dir(DATA_DIR, '\.mff$'));
        files = somsds.link2files(files, OUTPUT_DIR);
end

% files should now be a cell array containing the full paths to the files
% that are to be splitted (or, rather, the full paths to the symbolic links
% that point to those files).

% This is kind of obvious...
run(myPipe, files{:});

end