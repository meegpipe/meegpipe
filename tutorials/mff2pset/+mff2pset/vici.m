function vici(subjIDs)
% VICI - Run the conversion for VICI recording files
%
%  mff2pset.vici(subjIDs)
%
% Where
%
% SUBJIDS is a numeric array of subject IDs. By default, SUBJIDS=[1:200].
%
% See also: mff2pset

if nargin < 1,
    subjIDs = 1:200;
end

% We want to generate a physioset that uses single precision
myImporter = physioset.import.mff('Precision', 'single');

% Build a node that nodes how to generate a physioset from an .mff file
myNode = meegpipe.node.physioset_import.new(...
    'Importer', myImporter, ... % Read data from an .mff file
    'Save',     true, ...       % Save the node output (as a .pset/pseth)
    'OGE',      true, ...       % Use Open Grid Engine, if available
    'Queue',    'short.q@somerenserver.herseninstituut.knaw.nl', ...
    'Name',     'mff2pset' ...  % Optional, just to have nice dir names
);

% Create symbolic links to all sleep .mff files in the ssmd recording
files = somsds.link2rec('vici', ...
    'modality',     'eeg', ...
    'condition',    'sleep', ...
    'subject',      subjIDs,  ...     
    'file_ext',     '.mff', ...
    'folder',       '/data1/projects/vici-sleep/recordings/mff2pset' ...  % generate the links under this directory
    );

run(myNode, files{:});

end