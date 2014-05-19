Splitting a sleep recording into sleep stages
===

This tutorials illustrates how _meegpipe_ can be used to split a whole night
sleep recording into a set of files that contain only data from the same 
sleep stage. That is, we have a set of large files (in `.pset/.pseth` 
format) like:

````
ssmd_0104_eeg_sleep_1.pset
ssmd_0104_eeg_sleep_1.pseth
...
ssmd_0105_eeg_sleep_1.pset
ssmd_0105_eeg_sleep_1.pseth
```` 

And, for each pair of `.pset/.pseth` files we want to produce smaller files
that contain only data from a given sleep stage, i.e. something like:

````
ssmd_0104_eeg_sleep_1_wakefulness.pset
ssmd_0104_eeg_sleep_1_wakefulness.pseth
ssmd_0104_eeg_sleep_1_nrem1.pset
ssmd_0104_eeg_sleep_1_nrem1.pseth
...
````


## Preliminaries

Before anything else you need to ensure that EEGLAB is in your MATLAB 
search path. You also need to initialize _meegpipe_:

````
addpath(genpath('/data1/toolbox/eeglab'));
meegpipe.initialize;
````

## Retrieve sleep data and sleep scores

I assume that you are working at `somerengrid` (our lab's private computing
grid) and that the relevant sleep data files are managed by the
 [somsds][somsds] data management system. Thus we can retrieve the 
relevant data files for recording `ssmd` and subjects `1` to `500` as
 follows:

[somsds]: http://www.germangh.com/somsds/

````matlab
% Create symbolic links to the relevant sleep recordings
files = somsds.link2rec('ssmd', ...
    'subject',      1:500, ...
    'modality',     'eeg', ...
    'condition',    'sleep', ...
    'file_regex',   'pset.?$' ...  % Only files in pset/pseth format
);
````

The command above will generate symbolic links with names like:

````
ssmd_0104_eeg_sleep_1.pset
ssmd_0104_eeg_sleep_1.pseth
...
ssmd_0105_eeg_sleep_1.pset
ssmd_0105_eeg_sleep_1.pseth
````

You will need to manually place the `.mat` files with the sleep scores (as
produced by Giovanni Piantoni' [sleep scoring toolbox][sctoolbox]) within
 the same directory where the links above are located. Also the names of 
sleep scores `.mat` files must follow the naming convention illustrated 
below:

[sctoolbox]: https://github.com/gpiantoni/sleepscoring

````
ssmd_0104_eeg_sleep_1.pset
ssmd_0104_eeg_sleep_1.pseth
ssmd_0104_eeg_scores_sleep_1.mat
...
ssmd_0105_eeg_sleep_1.pset
ssmd_0105_eeg_sleep_1.pseth
ssmd_0105_eeg_scores_sleep_1.mat
````


## Building the pipeline


## Splitting the sleep recordings into sleep stages


## Where are the converted files?

As usual, _meegpipe_ stores the processing results for file `fileX.pseth` 
under a directory called `fileX.meegpipe`. Under Linux or Mac OS X you can
 use the shell utility `find` to locate the files you want. For instance, 
you could move all _wakefulness_ and _rem_ data splits to directory 
`/data/splits` using the following shell commands:

````
find ./ -regex '.*_(wakefulness|rem)\.pset.*' | xargs -I{} cp "{}" /data/splits
```` 
