`config` for `psd_ratio` criterion
========

This class holds configuration options for the [psd_ratio][psd_ratio] 
criterion.

[psd_ratio]: ./README.md


## Usage synopsis

```matlab
import spt.criterion.*;
myCfg  = psd_ratio.config.new('Band1', [0 20], 'Band2', [30 50]);
myCrit = psd_ratio.new(myCfg);
``` 

Or, alternatively:

```matlab
import spt.criterion.*;
myCrit  = psd_ratio.new('Band1', [0 20], 'Band2', [30 50]);
```

## Configuration options

Criterion `psd_ratio` accepts all configuration options accepted by its 
parent [rank criterion][rank]. 

[rank]: ../+rank/config.md


### `Band1`

__Class__: `1x2 numeric array`

__Default__: `[]`

The band of interest, i.e. the band where you expect the signal of interest
to have a higher SNR.


### `Band2`

__Class__: `1x2 numeric array`

__Default__: `[]`

The reference band, i.e. the band where you expect the signal of interest 
to have lowest SNR.


### `Estimator`

__Class__: `function_handle`

__Default__: `@(x, sr) pwelch(x, min(ceil(numel(x)/5),sr*3), [], [], sr)`

The spectral estimator used to compute the power in the band of interest 
and in the reference band. `Estimator` is defined as function handle that 
takes two arguments: a time series, and the corresponding sampling rate. 
The output produced by `Estimator` is a PSD object with the corresponding
power spectral density.


### `Band1Stat`

__Class__: `function_handle`

__Default__: `@(power) prctile(power, 75);`

The statistic used to summarize power in the band of interest. The default 
value of `Band1Stat` uses the 75% percentile of the power values across all
frequency bins within the band of interest.


### `Band2Stat`

__Class__: `function_handle`

__Default__: `@(power) prctile(power, 25)`

The statistic used to summarize power in the reference band.
