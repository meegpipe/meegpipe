Converting `.mff` files into meegpipe's `.pset/.pseth` format
===

This tutorials illustrates how _meegpipe_ can be used to convert a large 
number of hdEEG files in [EGI Netstation][egi]'s `.mff` into meegpipe's 
`.pset/.pseth` format. 

Typically, the first stage of any processing pipeline involves building a 
[physioset][physioset] based on the contents of a disk file in
a given standard (e.g. [edf][edf]) or proprietary (e.g. `.mff`) data
format. This data conversion step can be a very costly operation. 
For an 8-hours long hdEEG recording in `.mff` format it may easily take 
30 minutes or longer to build the corresponding physioset. Thus, it is 
often a good idea to build a separate pipeline to convert all raw data
files into _meegpipe_'s `.pset/.pseth` format, especially if you plan to run 
multiple pipelines (or multiple pipeline configurations) on the same set 
of files.  Building a physioset from a `.pset/.pseth` is a cheap operation
that will take only a few seconds to complete in most cases.

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
But in this case this is not really necessary. It is easier to simply
process all `.mff` files using the `physioset_import` node directly as we
do below.



## Converting a batch of files

First we need to get the full paths to all the relevant `.mff` files in a
cell array of strings. If you are working at `somerengrid` (the private 
computing grid of the Sleep&Cognition team) then the code below will 
generate a list of paths to all sleep files within the `ssmd` recording (
the code name for the _Sleep Stage Misperception_ project):

````matlab
files = somsds.link2rec('ssmd', ...
    'modality',     'eeg', ...
    'condition',    'sleep', ...
    'file_ext',     '.mff', ...
    'folder',       'mff2pset', ... % Directory where the links will be created
    );

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

Recall that _meegpipe_ always stores the processing results for file 
`fileX.mff`  under a directory called `fileX.meegpipe`. Under Linux or
 Mac OS X you can easily find the converted files using the shell command 
line utility `find`:

````
find ./ -regex '.*_mff2pset.pset.*'
````

The following shell command would move converted files to directory 
`/data1/import/ssmd/140517`:

````
find ./ -regex '.*_mff2pset.pset.*' | xargs -I{} mv "{}" /data1/import/ssmd/140517
```` 
