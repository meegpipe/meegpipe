`config` for node `generic_features`
===

This class is a helper class that implements consistency checks necessary for
building a valid [generic_features][generic_features] node.

[generic_features]: ./README.md

## Usage synopsis

For all channels extract the following sets of features:

* The average signal amplitude in blocks 4, 5, 7, normalized by the average
signal amplitude in blocks 2 and 3.

* The average signal amplitude across all blocks.

We will assume that block onsets and durations are marked by events of 
type `block`, and that the block number is stored in the `Value` property
of the correspoding block event.


````matlab
import meegpipe.*;
import physioset.event.value_selector;

mySel1 = pset.selector.event_selector(value_selector(4,5,7));
mySel2 = pset.selector.event_selector(value_selector(2,3));
mySel3 = pset.selector.event_selector(value_selector(8));

myFirstLevelFeature  = @(x, ev) mean(x);
mySecondLevelFeature = {@(x, selectorObj) x(1)/x(2), ...
    @(x, selectorArray) mean(x)};

myConfig = node.generic_features.new(...
    'TargetSelector', {mySel1, mySel2, mySel3}, ...
    'FirstLevel',     myFirstLevelFeature, ...
    'SecondLevel',    mySecondLevelFeature, ...
    'FeatureNames',   {'funnyratio'});

myNode = generic_features.new(myConfig);
````

The following syntax is equivalent:


````matlab
import meegpipe.*;
import physioset.event.value_selector;

mySel1 = pset.selector.event_selector(value_selector(4,5,7));
mySel2 = pset.selector.event_selector(value_selector(2,3));
mySel3 = pset.selector.event_selector(value_selector(8));

myFirstLevelFeature  = @(x, ev) mean(x);
mySecondLevelFeature = {@(x) x(1)/x(2), ...
    @(x, evArray) (get_duration(evArray)./sum(get_duration(evArray))).*x};

myConfig = node.generic_features.config(...
    'TargetSelector', {mySel1, mySel2, mySel3}, ...
    'FirstLevel',    myFirstLevelFeature, ...
    'SecondLevel',   mySecondLevelFeature, ...
    'FeatureNames',   {'funnyratio'});

myNode = node.generic_features.new(myConfig);
````


## Configuration properties


The following construction options are accepted by the constructor of
this config class, and thus by the constructor of the `erp` node class:


### `TargetSelector`

__Class__: `pset.selector.selector`

__Default__: `[]`, i.e. select all data



### `FirstLevel`

__Class__: `function_handle`

__Default__: `@(x) mean(x)`


### `SecondLevel` 

__Class__: `function_handle`

__Default__: `@(x) mean(x)`


### `FeatureNames`

__Class__: `cell array of strings`

__Default__: `{'mean'}`

