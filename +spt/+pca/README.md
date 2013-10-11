`spt.pca`
==========

Package `spt.pca` implements a spatial tranformations based on
[Principal Component Analysis][wiki-pca]. The main component of the package is
the [spt.pca.pca][./@pca/pca.m] class.

## Usage synopsis

```matlab
import spt.*;
myPCA = pca.new;
myPCA = pca.new('key', value, ...);
myPCA = learn(myPCA, myData);
myPCs = proj(myPCA, myData);
```

To project a physioset object into its 5 first principal components:


```matlab
import spt.*;

% Generate a sample physioset
myData = import(physioset.import.matrix, rand(10, 10000));

myPCA = pca.new('MaxDimOut', 5, 'MinDimOut', 5);
myPCA = learn(myPCA, myData);
myPCs = proj(myPCA, myData);
```
where `myPCs` is a `pset` object of dimensions `5x10000` that contains the
top 5 principal components of `myData`.


## Accepted constructuction arguments

Construction arguments can be specified as `'key', value` pairs:

```matlab
import spt.*;
myPCA = pca.new('key', value, ...)
```

### `Var`

__Class__: `1x2 numeric vector`

__Default__: `[0 1]`

A 2-element vector especifying the minimum and maximum (normalized) variance
that can be attributed to the selected principal components. For instance, if
`Var` is set to  `[0.25 0.75]`, the PCA components selected by the algorithm are
will explain at least 25% and at most 75% of the input data variance. Note that
other construction arguments may override this behavior, e.g. see
argument `MaxDimOut` below.

### `MaxDimOut`

__Class__: `natural scalar` or `Inf`

__Default__: `Inf`

Maximum number of principal components. `MaxDimOut` takes preference over any
other construction argument. That is, the number of estimated principal
components will never exceed `MaxDimOut`.

### `Criterion`

__Class__: `string`

__Default__: `'max'`

An information-theoretic criterion criterion for PCA order selection. The
currently implemented choices are: `'mibs'`, `'aic'`, `'mdl'`, `'max'`.
Criterion `'max'` is a dummy criterion that will simply select as many principal
components as the rank of the input data.

### `MinSamples`

__Class__: `numeric`

__Default__: `0`

The minimum value of the ratio `(samples)/(dim^2)` with `samples` the number of
data samples and `dim` the number of seletected principal components. This
argument is useful when you want to enforce that number of sample per dimension
is large enough to ensure that enough information is available for subsequent
learning stages (e.g. for ICA).

### `Sphering`

__Class__: `logical scalar`

__Default__: `false`

If set to true, the principal components will be spheric, i.e. they will all
have unit variance and zero mean.


## Methods

See the methods implemented by the parent class [spt.generic.generic][generic].

[generic]: ../+generic/README.md
