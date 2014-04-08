Minimizing EMG activity using BSS-CCA
===

This tutorials illustrates how _meegpipe_ can be used to correct muscle
artifacts using [Canonical Correlation Analysis][cca]. The original method
details are described in the following scientific reference:

> De Clercq, W. et al., _Canonical Correlation Analysis Applied to Remove Muscle
Artifacts from the Electroencephalogram_, IEEE Trans. Biomed. Eng. 53 (12), pp.
2583-2587. DOI: [10.1109/TBME.2006.879459](http://dx.doi.org/10.1109/TBME.2006.879459)

[cca]: http://en.wikipedia.org/wiki/Canonical_correlation

## Prerequisites

I am going to assume that you have already installed and ininitialized
_meegpipe_. If you haven't done so, then please follow the [installation
instructions](http://germangh.com/meegpipe). For this tutorial you do not need
to install any of the recommended dependencies.

## The sample dataset

For this tutorial I will use a [sample data epoch][data] from the dataset that
was used in the publication below:

[data]: https://dl.dropboxusercontent.com/u/4479286/meegpipe/f1_750to810.set

> Gomez-Herrero, G et al., _Automatic removal of ocular artifacts in the EEG_
> _without a reference EOG channel _, Proc. NORSIG 2006, pp. 130-133, 2006.
> DOI:
> [10.1109/NORSIG.2006.275210](http://dx.doi.org/10.1109/NORSIG.2006.275210)

Start MATLAB and get the sample dataset by copying and pasting the following
code into MATLAB's command window:

````matlab
unzip('https://dl.dropboxusercontent.com/u/4479286/meegpipe/f1_750to810.zip');
````

## The cleaning pipeline

The EMG cleaning pipeline is going to consist of three nodes: One for importing
the data (in EEGLAB's `.set` format), one for performing the cleaning/filtering
operation, and one to export the result back into EEGLAB's `.set` format. The
code snippet below defines and builds such a pipeline:

````matlab
% This cell array will store the list of nodes
nodeList = {};

% The first node: imports .set files into MATLAB
myImporter = physioset.import.eeglab;
myNode = meegpipe.node.physioset_import.new('Importer', myImporter);
nodeList = [nodeList {myNode}]

% The second node: uses a BSS-CCA filter to try to minimize EMG artifacts
% CCA is performed in sliding windows of 5 seconds (with 50% overlap) and the
% correction threshold is set to 50% (0%=no correction, 100%=output is flat).
myNode = aar.emg.cca_sliding_window(...
    'WindowLength',     5, ...
    'WindowOverlap',    50, ...
    'Correction',       50);
nodeList = [nodeList {myNode}]

% The third node: store the results as an EEGLAB's .set file
myExporter = physioset.export.eeglab;
myNode = meegpipe.node.physioset_export.new('Exporter', myExporter)
nodeList = [nodeList {myNode}]

% We are now ready to build the pipeline
myPipe = meegpipe.node.pipeline.new('NodeList', nodeList);
````

We can now clean the sample data file using:

````matlab
run(myPipe, 'f1_750to810.set');
````


