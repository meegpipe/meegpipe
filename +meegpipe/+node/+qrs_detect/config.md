`config` for node `qrs_detect`
===


This class is a helper class that implements consistency checks
necessary for building a valid [qrs_detect][qrs_detect] node.

[qrs_detect]: ./README.md

## Usage synopsis:


````matlab
import meegpipe.node.*;
myConfig = qrs_detect.config('Event', physioset.event.std.qrs);
myNode   = qrs_detect.new(myConfig);
````
The following syntax is equivalent, and preferable for being more concise:

````matlab
import meegpipe.node.*;
myNode = qrs_detect.new('Event', physioset.event.std.qrs);
````

## Configuration properties

The following construction options are accepted by the constructor of
this config class, and thus by the constructor of the `qrs_detect`
class:

### `Event`

__Class__: `physioset.event.event`

__Default__: `physioset.event.std.qrs`

Events of the same class as the provided event will be used to mark the
locations of the QRS complexes.

