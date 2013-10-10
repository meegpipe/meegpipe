`config` - Configuration for node `bss_regr`
=====

This class is a helper class that implements consistency checks
necessary for building a valid [bss_regr][bss_regr] node. 

[bss_regr]: ./README.md


## Usage synopsis:

Create a `bss_regr` node that will (1) decompose the raw data into a set of
[FastICA][fastica] independent components (ICs), and (2) reject all those
ICs of ocular origin. There are several ways you may attempt to 
automatically identify spatio-temporal components of ocular origin. In this
example we use a simple criterion based on ranking the spatial components 
according to their [fractal dimension][fd]. This is the same criterion that
was used in:

[fd]: http://arxiv.org/abs/1003.5266
[fastica]: http://research.ics.aalto.fi/ica/fastica/

* Gomez-Herrero, G. et al., _Automatic removal of ocular artifacts in the
  EEG without a reference EOG channel_, in Proc. NORSIG, Reykjavik, 
  Iceland, pp. 130-133, 2006. Free download: http://kasku.org/pubs/norsig06.pdf. 
  DOI: [10.1109/NORSIG.2006.275210](http://dx.doi.org/10.1109/NORSIG.2006.275210)

Below you have the MATLAB code necessary to build the desired `bss_regr` 
node:

````matlab
import meegpipe.node.*;
% Criterion to identify ocular components
myCriterion = spt.criterion.tfd.eog;
% Build a configuration object
myConfig = bss_regr.config('Criterion', myCriterion);
% Use the configuration object to build a bss_regr node
myNode = bss_regr.new(myConfig);
````

The following syntax is completely equivalent:

````matlab
import meegpipe.node.*;
myCriterion = spt.criterion.tfd.eog;
myNode = bss_regr.new('Criterion', myCriterion);
````

The latter syntax is to be preferred over the former, for the simple reason
of being more concise.

## Configuration properties

The following construction options are accepted by the constructor of 
this `config` class, and thus by the constructor of the `bss_regr`
class:

### `PCA`

__Class__ : `spt.pca.pca`

__Default__: `spt.pca.pca('Criterion', 'aic', 'Var', [0.95 0.9999], 'MaxDimOut', 50)`

The specifications of the [principal component analysis][pca-wiki] step 
that is performed before estimating the spatial components using BSS.

[pca-wiki]: https://en.wikipedia.org/wiki/Principal_component_analysis


### `BSS`

__Class__: `spt.bss.bss`

__Default__ `spt.bss.jade.jade`

The [Blind Source Separation][bss-wiki] algorithm that will be used to 
decompose the input data into a set of spatio-temporal components. 

[bss-wiki]: https://en.wikipedia.org/wiki/Blind_signal_separation

### `RegrFilter`

__Class__: `filter.rfilt`

__Default__: `[]`

An optional filter that will be used to regress-out the time-courses of the
rejected components from the raw measurements. This filter can be used 
to remove any residual artifact-related activity that may remain in the 
data due to a sub-optimal separation of the underlying artifactual sources
in the BSS step. 

For instance, you could enforce the use of a 4-lag regression filter by 
setting `RegrFilter` to `filter.mlag_filter('Order', 4)`.


### `ChopSelector`

__Class__: `physioset.event.selector`

__Default__: `physioset.event.class_selector('Class', 'chop_begin')`

This event selector will be used to identify physioset events that indicate
chop boundaries. The BSS step will be performed on each such data chop 
separately.


### `Overlap`

__Class__: `numeric` (a percentage)

__Default__: `25`

The overlap between correlative analysis windows. This option has an effect
only in the presence of multiple data chops. The analysis windows that 
will be independently passed to the BSS step will be defined as a given 
data chop and an `Overlap`% of the data from the previous and next data 
chops. This parameter is typically used to ensure that the BSS 
decompositions of correlative data chops are fairly similar. 


### `Criterion`

__Class__ : `spt.criterion.criterion`

__Default__ : `spt.criterion.dummy.dummy`
		  
The automatic criterion for identifying the spatio-temporal components 
that are to be rejected, or accepted (depending on the value of the 
`Reject` property, see below). 


### `Reject`

__Class__ : `bool`

__Default__: `true`

If set to `true`, the components identified with the provided criterion 
will be _rejected_, i.e. the output of the `bss_regr` node will be 
produced by backprojecting all spatio-temporal components except those
that were selected with the provided criterion. 

If set to `false`, the output of `bss_regr` will be produced by 
back-projecting only the components selected by the criterion. That is, 
the components identified by the criterion will be _accepted_ instead of 
being _rejected_. 


### `FixNbICs`

__Class__ : `natural scalar` or `function_handle`

__Default__: `@(x,y) round(prctile(x, 75));`

Typically, one wants fairly similar processing results across correlative
data chops. One way to enforce this is by setting a large `Overlap` 
between correlative analysis windows so that the spatio-temporal components
across correlative data chops are similar. Additionally, one often wants 
to enforce that the same number of components are _rejected_ (or
_accepted_) in every data chop. Option `FixNbICs` provides two ways of 
achieving this:

* If `FixNbICs` is set to a natural scalar, then the `FixNbICs`
  top-ranked (according to the provided `Criterion`) components will be 
  _rejected_ (or _accepted_ depending on option `Reject`) in every data 
  chop. 

* If `FixNbICs` is set to a `function_handle` that takes two arguments 
  the actual number of top-ranked components that will be marked for 
  _rejection_ or _acceptance_ will be calculated as follows:

````matlab
actualFixNbICs = FixNbICs(chopNbICs, PCADimOut)
````

where `chopNbICs` is an array with the number of components that were 
automatically selected by the criterion in each data chop, and `PCADimOut` 
is the number of principal components (a scalar). 

For instance, to ensure that half of the available spatial components are 
rejected in every window you should set `FixNbICs` to `@(x,y) round(y/2)`.


### `Filter`

__Class__: `filter.dfilt`

__Default__: `[]`

If applicable, the time-courses of the identified spatio-temporal components
will be filtered with the provided `Filter` before backprojecting the 
components. This option is typically used to ensure that no brain activity 
is removed from the data when rejecting e.g. ocular components. For 
instance you may set `Filter` to `filter.lpfilt('fc', 0.2)` to low-pass 
filter the ocular components' time series before back-projecting (and 
rejecting) them. This is justified by the fact that ocular activity is 
largely concentrated in the low frequencies.

