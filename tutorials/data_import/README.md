Importing a batch of `.mff` files into meegpipe's format
===

This tutorials illustrates how _meegpipe_ can be used to convert a large 
number of hdEEG files in [EGI Netstation][egi]'s `.mff` into meegpipe's 
`.pset/.pseth` format. 

Typically, the first stage of any processing pipeline involves building a 
[physioset][physioset] based on the contents of a disk file in
 certain standard (e.g. [edf][edf]) or proprietary (e.g. `.mff`) data
format. However, this data conversion step can be a very costly operation. 
For an 8-hours long hdEEG recording in `.mff` format it may easily take 
30 minutes or longer to build the corresponding physioset. Thus, if the raw
data files that you are dealing with are very large and you have enough
disk space, it is a good idea to build a separate pipeline for converting 
all files into meegpipe's `.pset/.pseth` format. Building a physioset from 
a `.pset/.pseth` is a cheap operation that will typically take just a few
seconds to complete.

[egi]: http://www.egi.com/research-division/geodesic-eeg-system-components/eeg-software
[edf]: http://www.edfplus.info/
[physioset]: https://github.com/meegpipe/meegpipe/blob/master/%2Bphysioset/%40physioset/README.md

Before anything else you need to ensure that EEGLAB is in your MATLAB 
search path and initialize meegpipe:

````
addpath(genpath('/data1/toolbox/eeglab'));
meegpipe.initialize;
````


## Building the pipeline

The code snippet below will build a data processing node that (1) 
reads data from a disk file in `.mff` format and (2) saves the generated 
physioset in meegpipe's `.pset/.pseth` format. 

````matlab
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
```` 

We could now build a pipeline with a single node like this:

````matlab
myPipe = meegpipe.node.pipeline.new('NodeList', {myNode});
````
But in this case this is not really necessary as our pipeline would only 
have one node. It is just simpler to process all `.mff` files using the 
`physioset_import` node directly as we do below.

## Converting a batch of files

First we need to get the full paths to all the relevant `.mff` files in a
cell array of strings. If you are working at `somerengrid` (the private 
computing grid of the Sleep&Cognition team) then the code below will 
generate a list of paths to all sleep files within the `ssmd` recording (
the code name for the Sleep Stage Misperception project):

````matlab
files = somsds.link2rec('ssmd', ...
    'modality',     'eeg', ...
    'condition',    'sleep', ...
    'file_ext',     '.mff');

% files should now be a cell array of strings containing something like:
% files = { ...
%   '/path/to/workdir/ssmd/ssmd_0001_sleep_1.mff', ...
%   '/path/to/workdir/ssmd/ssmd_0001_sleep_2.mff', ...
%   ...   % Lots of other file paths here
%   '/path/to/workdir/ssmd/ssmd_0140_sleep_2.mff' ...
% }
````

Now we can just process all files using the `physioset_import` node that 
built above:

````matlab
run(mNode, files{:});
````

## Where are the converted files?

Under Linux or Mac OS X you can easily find the converted files using this 
command in a shell window:

````
find ./ -regex '.*_mff2pset.pset.*'
````

The following shell command will copy move converted files to directory 
`/data1/import/ssmd/140517`:

````
find ./ -regex '.*_mff2pset.pset.*' | xargs -I{} cp "{}" /data1/import/ssmd/140517
```` 
