`dummy` criterion
========

Package `spt.criterion.dummy` contains a dummy implementation of a 
component selection criterion. This implementation can be used as a 
template for your own custom criteria. 

## Usage synopsis

```matlab
import spt.criterion.*;
import spt.bss.*;

% Estimate Fastica components from a random dataset
myData   = rand(10, 1000);
mySptObj = learn(fastica.new, myData);
mySptAct = proj(mySptObj, myData);

% Select (and rank) some components using a dummy criterion
myCrit = spt.criterion.dummy.new('DummyProp1', 7);
[idx, rankIdx] = select(myCrit, mySptObj, mySptAct);
```


## Criterion configuration

See the documentation of the associated [config][config] class. 

[config]: ./config.md