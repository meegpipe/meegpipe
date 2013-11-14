package `spt.criterion.var`
========

Package `spt.criterion.var` defines a spatial component selection criterion 
that selects componens that explain a large proportion of the observed data 
variance (at the sensor level).


## Usage

````matlab

% Create a sample dataset by mixing some independent components using a 
% a randomly generated mixing matrix
data = spt.criterion.var.sample_data;

% Perform ICA on the sample dataset using the EFICA algorithm
sptObj = learn(spt.bss.efica.new, data);
ics    = proj(sptObj, data);

% Select the 4 components that explain most of the observed data variance
myCrit = spt.criterion.var.new('MaxCard', 4, 'MinCard', 4);
[selection, rankIndex] = select(myCrit, sptObj, ics, [], [], [], data);

% The indices of the selected components
find(selection)
````

## Construction arguments

The `var` criterion admist all the key/value pairs admitted by the
[spt.criterion.rank][rank-crit] criterion. For keys specific to the 
`var` criterion see the documentation of the helper [config][config] class.

[rank-crit]: ../+rank/README.md
[config]: ./config.md

