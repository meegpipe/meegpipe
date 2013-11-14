`config` for `dummy` criterion
========

This class holds configuration options for the `dummy` criterion.

## Usage synopsis

```matlab
import spt.criterion.*;
myCfg  = dummy.config.new('DummyProp1', 1, 'DummyProp2', 0);
myCrit = dummy.new(myCfg);
``` 

Or, alternatively:

```matlab
import spt.criterion.*;
myCrit  = dummy.new('DummyProp1', 1, 'DummyProp2', 0);
```

## Configuration options


### `DummyProp1`

__Class__: `natural scalar` 

__Default__: `4`

Some explanations on what `DummyProp1` is for.


### `DummyProp2`

__Class__: `numeric` 

__Default__: `0`

Some explanations on what `DummyProp2` is for.