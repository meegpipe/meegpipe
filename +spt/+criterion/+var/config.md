`config` for criterion `var`
======

This class is a helper class that implements consistency checks
necessary for building a valid [var][var] criterion. 

[var]: ./README.md

## Usage synopsis

Create a `var` criterion that will select the 5 components that explain 
most variance at the `EEG 124` channel:

````matlab
import spt.criterion.*;
myConfig = var.config.new('MinCard', 5, 'MaxCard', 5, ...
    'ChannelSet', '^EEG 124$');
myCriterion = var.new(myConfig);
````

The syntax above is completely equivalent to the (preferred) syntax below:

````matlab
import spt.criterion.*;
myConfig = var.new('MinCard', 5, 'MaxCard', 5, 'ChannelSet', '^EEG 124$');
````

## Configuration properties

Note that the constructor of this configuration class admits all the 
construction arguments accepted by the constructor of the parent 
[rank configuration class][rank-cfg]. Below you can find a list of the 
construction arguments that are specific to the configuration of `var`
criterion objects:

[rank-cfg]: ../+rank/config.md

### `ChannelSet`

__Class__ : `cell array` or `[]`

__Default__ : `[]`
		  
The subset of data channels to consider when calculating the observed 
variance. If set of `[]`, all data channels will be considered. 

Channel subsets can be specified in several ways. One possibility is to 
specify it using a cell array of string literals that should be matched 
against the channel labels. For instance, the criterion object build 
below will consider only the channels with labels `EEG 1` and `EEG 2`:

````matlab
import spt.criterion.var.*;
myCrit = var.new('ChannelSet', {{'EEG 1', 'EEG 2'}});
````

Another alternative is to use a regular expression. The following criterion
object will behave identically to the one we built above:

````matlab
import spt.criterion.var.*;
myCrit = var.new('ChannelSet', {'^EEG (1|2)$'});
````

A list of regular expressions and/or string literals can be provided as 
shown in the example below:

````matlab
import spt.criterion.var.*;
myCrit = var.new('ChannelSet', {'^EEG (1|2)$', {'EEG 4', 'EEG 5'}, ...
    '^EEG \d\d\d$'});
````

which will select channels with labels `EEG 1`, `EEG 2`, `EEG 4`, `EEG 5` 
and `EEG #number` where `#number` is any 3-digits number.





[crit-pkg]: ./+criterion/README.md
