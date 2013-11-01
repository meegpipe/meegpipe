`bad_epochs` - bad epochs rejection node
====

The `bad_epochs` node identifies and marks bad epochs in a physioset, based on
a user-provided criterion. Several [pre-defined criteria][predef-crit] are
available and class users can easily define their own custom criteria.

[predef-crit]: ../+criterion/README.md


## Usage synopsis

````matlab
import meegpipe.node.*;
obj = bad_epochs.new('key', value, ...);
data = run(obj, data);
````

where `data` is a [physioset][physioset] object.

[physioset]: ../../../+physioset/@physioset/README.md


## Construction arguments

The `bad_epochs` node admits all the key/value pairs admitted by the
[abstract_node][abstract-node] class. For keys specific to this node
class see the documentation of the helper [config][config] class.

[abstract-node]: ../@abstract_node/README.md
[config]: ./config.md


## Methods

See the documentation of the [node API documentation][node].

[node]: ../



## Usage examples

All the examples below assume that _meegpipe_ has been initialized using:

````matlab
clear all;
meegpipe.initialize;
````

### Reject epochs with extreme values

The following code snippet rejects all 10-second epochs in a physioset `data`
that exceed (in any channel, in absolute value) a threshold of 100.

````
% Create a sample physioset
mySensors = subset(sensors.eeg.from_template('egi256'
myImporter = physioset.import.matrix('Sensors', mySensors);
myData = import(physioset.import.matrix, 
````
