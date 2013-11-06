`config` for node `abp`
===


This class is a helper class that implements consistency checks
necessary for building a valid [abp][abp] node.

[abp]: ./README.md

## Usage synopsis


````matlab
import meegpipe.node.*;
myConfig = abp.config('key', value, ...);
myNode   = abp.new(myConfig);
````

Altenatively, the following syntax is equivalent and preferable:

````matlab
import meegpipe.node.*;
myNode = abp.new('key', value, ...);
````


## Configuration properties


The following construction options are accepted by the constructor of
this config class, and thus by the constructor of the `abp` node
class:


### `RPeakEventSelector`

__Class__: `physioset.event.selector`

__Default__: `[]`

The event selector that will select the subset of events marking the 
locations of the R-peaks. 

