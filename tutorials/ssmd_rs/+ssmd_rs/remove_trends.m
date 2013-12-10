function remove_trends
% REMOVE_TRENDS - Remove large amplitude trends in the SSMD datasets
%
% Depending on the filter that we use for detrending, this step can take a
% very long time to compute. That is why we have it as a separate pipeline,
% instead of having it as an additional node of the EEG cleaning pipeline.

% Start in a completely clean state
close all;
clear all;
clear classes;

meegpipe.initialize;

% Import some miscellaneous utilities
import misc.dir;
import mperl.file.spec.catfile;
import mperl.file.spec.catdir;
import misc.get_hostname;
import misc.get_username;

% The output directory where we want to store the splitted data files
switch lower(get_hostname),
    case {'somerenserver', 'nin389'}
        % If we are running this at somerengrid
        OUTPUT_DIR = catdir('/data1/projects/meegpipe/ssmd_rs_tut', ...
            get_username, 'remove_trends_output');
    otherwise,
        % If German is running this in his laptop
        OUTPUT_DIR = '/Volumes/DATA/tutorial/ssmd_rs/remove_trends_output';
end

% Some (optional) parameters that you may want to play with when experimenting
% with your processing pipeline
PARALELLIZE = true; % Should each file be processed in parallel?
DO_REPORT   = true; % Should full HTML reports be generated?

% Create an instance of your detrending pipeline
myPipe = batman.remove_trends(...
    'GenerateReport', DO_REPORT, ...
    'Parallelize',    PARALELLIZE);

% Note that we have not yet written function splitting_pipeline!

% Generate links to the relevant data files into the output directory. This
% step is equivalent to copying the relevant data files into the output
% directory but has the advantage of saving valuable disk space. The
% command below will only work at somerengrid.
switch lower(get_hostname),
    case {'somerenserver', 'nin389'}
        % If we are running this at the somerengrid, use link2rec to get
        % symbolic links to the relevant data files
        files = somsds.link2rec(...
            'batman', ...           % The recording ID
            'subject', 102:104, ...   % The subject ID(s)
            'cond_regex', 'rs-', ...  % The data modality
            'folder',  OUTPUT_DIR); % The directory where the links will be generated
        
    case 'outolintulan',
        % If German is running this in his laptop
        DATA_DIR = '/Volumes/DATA/datasets/ssmd';
        files = catfile(DATA_DIR, dir(DATA_DIR, '\.mff$'));
        files = somsds.link2files(files, OUTPUT_DIR);
end

% files should now be a cell array containing the full paths to the files
% that are to be splitted (or, rather, the full paths to the symbolic links
% that point to those files).

% This is kind of obvious...
run(myPipe, files{:});

end