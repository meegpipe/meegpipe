`rank` criterion
========

Criterion `rank` is an abstract criterion to be used for inheritance. This 
criterion defines several [configuration options][config] that are accepted
by all its children criterion classes. You can find out whether a criterion
class inherits from `rank` using function `isa`. For instance, to determine
whether criterion `psd_ratio` inherits from `rank`:

```matlab
isa(spt.criterion.psd_ratio.new, 'spt.criterion.rank.rank')
```

which will return `true` meaning that criterion `psd_ratio` is a child
of criterion `rank`. 

[config]: ./config.md


