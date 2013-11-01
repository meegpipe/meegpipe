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

````matlab
% Create a sample physioset
mySensors  = sensors.eeg.dummy(10);
myImporter = physioset.import.matrix('Sensors', mySensors);
myData = import(myImporter, randn(10, 10000));

% We need to add events marking the onset and durations of the epochs
% As an example, we use non-overlapping epochs of 10s duration
import physioset.event.periodic_generator;
myEventGenerator = periodic_generator('Period', 10, 'Type', 'myType');
myEvents = generate(myEventGenerator, myData);
add_event(myData, myEvents);

% Define the epoch rejection criterion
import meegpipe.node.*;
myCrit = bad_epochs.criterion.stat(...
    'ChannelStat',  @(chanValues) max(abs(chanValues)), ...
    'EpochStat',    @(chanStat) max(chanStat));

% Define the event selector
myEvSel = physioset.event.class_selector('Type', 'myType');

% Build the epoch rejection node
myNode = bad_channels.new('Criterion', myCrit, 'EventSelector', myEvSel);

% Reject epochs that fulfill the rejection criterion
run(myNode, myData);

````
