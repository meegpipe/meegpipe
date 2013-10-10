`qrs_detect` - Detection of QRS complexes from ECG time-series
===

The `qrs_detect` node detects QRS complexes and introduces suitable events
at the occurrence times of such complexes. 


## Usage synopsis:

````matlab
import meegpipe.*;
obj = node.qrs_detect.new('key', value, ...)
run(obj, data);
````

where `data` is a [physioset][physioset] object.

[physioset]: https://github.com/germangh/matlab_physioset/blob/master/%2Bphysioset/%40physioset/README.md


## Construction arguments

The `qrs_detect` node admits all the key/value pairs admitted by the
[abstract_node][abstract-node] class. For configuration options specific to this
node class see the documentation of the helper [config][config] class.

[abstract-node]: ../@abstract_node/README.md
[config]: ./config.md


## Methods

See the documentation of the [node API documentation][node].

[node]: ../


