function split_files
% SPLIT_FILES - Split BATMAN's large .mff files into single-block files
%
% This is the first stage of the BATMAN processing chain. The input to this
% stage are the raw .mff files. The produced output is a set of
% single-block .pset/pseth files (meegpipe's own data format). By
% single-block we mean a single condition block (Baseline, PVT, RS, RSQ)
% within a given experimental manipulation.

meegpipe.initialize;

% Import some miscellaneous utilities
import misc.dir;
import mperl.file.spec.catfile;
import misc.get_username;

% The output directory where we want to store the splitted data files
OUTPUT_DIR = '/data1/projects/batman/analysis/split_files';

% Ensure the directory exists (Unix-specific)
system(['mkdir -p ' OUTPUT_DIR]);

% Some (optional) parameters that you may want to play with when
% experimenting with your processing pipeline
PARALLELIZE = true; % Should each file be processed in parallel?
DO_REPORT   = true; % Should full HTML reports be generated?

% Create an instance of your data splitting pipeline
myPipe = batman_eeg.split_files_pipeline(...
    'GenerateReport', DO_REPORT, ...
    'Parallelize',    PARALLELIZE);

% Note that we have not yet written function splitting_pipeline!

% Generate links to the relevant data files into the output directory. This
% step is equivalent to copying the relevant data files into the output
% directory but has the advantage of saving valuable disk space. The
% command below will only work at somerengrid.
files = somsds.link2rec(...
    'batman', ...           % The recording ID
    'subject', 1:10, ...   % The subject ID(s)
    'modality', 'eeg', ...  % The data modality
    'file_ext', '.mff', ...
    'folder',  OUTPUT_DIR); % The directory where the links will be generated


% files should now be a cell array containing the full paths to the files
% that are to be splitted (or, rather, the full paths to the symbolic links
% that point to those files).

% This is kind of obvious...
run(myPipe, files{:});

end