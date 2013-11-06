`abp` - Arterial Blood Pressure feature extraction
===

The `abp` node uses [physionet's ABP toolkit][abp-toolkit] to extract 
commonly used features from Arterial Blood Pressure time series. See the 
documentation of the ABP toolkit for more information.

[abp-toolkit]: http://www.physionet.org/physiotools/cardiac-output/

The `abp` node expects to find R-peak markers embedded in the phyioset for 
which the features should be extracted. You can produce such markers using 
an [ecg_annotate node][ecg_annotate]. 

[ecg_annotate]: ../+ecg_annotate/README.md


## Usage synopsis:

````matlab
import meegpipe.*;
obj = node.abp.new('key', value, ...)
run(obj, data);
````

where `data` is a [physioset][physioset] object.

[physioset]: ../../../+physioset/@physioset/README.md


## Construction arguments

The `abp` node admits all the key/value pairs admitted by the
[abstract_node][abstract-node] class. For configuration options specific to
this node class see the documentation of the helper [config][config] class.

[abstract-node]: ../@abstract_node/README.md
[config]: ./config.md


## Methods

See the documentation of the [node API documentation][node].

[node]: ../


