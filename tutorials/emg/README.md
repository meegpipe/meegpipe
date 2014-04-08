Minimizing EMG activity using BSS-CCA
===

This tutorials illustrates how _meegpipe_ can be used to correct muscle
artifacts using [Canonical Correlation Analysis][cca]. The original method
details are described in the following scientific reference:

> De Clercq, W. et al., _Canonical Correlation Analysis Applied to Remove Muscle
Artifacts from the Electroencephalogram_, IEEE Trans. Biomed. Eng. 53 (12), pp.
2583-2587. DOI: http://dx.doi.org/10.1109/TBME.2006.879459

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

> Gomez-Herrero, G et al., _Automatic removal of ocular artifacts in the EEG
> without a reference EOG channel _, Proc. NORSIG 2006, pp. 130-133, 2006.
> DOI:
> [10.1109/NORSIG.2006.275210](http://dx.doi.org/10.1109/NORSIG.2006.275210)

Start MATLAB and get the sample dataset by copying and pasting the following
code into MATLAB's command window:

````matlab
url = 'https://dl.dropboxusercontent.com/u/4479286/meegpipe/f1_750to810.set';
unzip(url, 'f1_750to810.set');
````
