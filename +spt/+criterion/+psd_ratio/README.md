`psd_ratio` criterion
========

Criterion `psd_ratio` ranks spatio-temporal components according to the 
ratio of power in a band of interest over the power in a reference band. 


## Usage synopsis

```matlab
import spt.criterion.*;
import spt.bss.*;

% Estimate Fastica components from a random physioset
myData   = import(physioset.import.matrix, rand(10, 1000));
mySptObj = learn(fastica.new, myData);
mySptAct = proj(mySptObj, myData);

% Select and rank components according to the amount of power they 
% concentrate in the band from 10 to 20 Hz relative to the power in the 
% band from 30 to 50 Hz
myCrit = spt.criterion.psd_ratio.new('Band1', [10, 20], 'Band2', [30 50]);
[idx, rankIdx] = select(myCrit, mySptObj, mySptAct);
```


## Criterion configuration

See the documentation of the associated [config][config] class. 

[config]: ./config.md