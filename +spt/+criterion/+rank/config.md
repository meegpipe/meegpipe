`config` for `rank` criterion
========

This class holds configuration options for the [rank][rank] criterion. 
Note that these configuration options are also accepted by all criterion 
classes that inherit from the `rank` criterion.

[rank]: ./README.md



## Configuration options


### `Percentile`

__Class__: `numeric scalar` in the range `[0 100]`

__Default__: `[]`

The components whose rank index value is above this percentile will be
 selected.


### `MaxCard`

__Class__: `numeric scalar` or `function_handle`

__Default__: `Inf`

Maximum number of selected components. If set to a `function_handle` the 
actual maximum number of selected components will be obtained by evaluating 
`MaxCard` on the number of input components. 

__IMPORTANT__: This configuration option takes preference over any other 
configuration option. That is, you can be sure that you will never get more 
than `MaxCard` components being selected.


### `MinCard`

__Class__: `numeric scalar` or `function_handle`

__Default__: `0`

If set to a `function_handle` the 
actual maximum number of selected components will be obtained by evaluating 
`MinCard` on the number of input components. 

__IMPORTANT__: This configuration option takes preference over any other 
configuration option. That is, you can be sure that you will never get less 
than `MinCard` components being selected (of course assuming that there 
were at least `MinCard` components to begin with).


### `Min`

__Class__: `numeric scalar` or `function_handle`

__Default__: `-Inf`

Minimum rank index value for a component to be selected. If set to a 
`function_handle` then the actual minimum rank threshold will be obtained
by evaluating `Min` on the vector of rank values for each input component.


### `Max`

__Class__: `function_handle`

__Default__: `Inf`

Minimum rank index value for a component to be selected. If set to a 
`function_handle` then the actual maximum rank threshold will be obtained
by evaluating `Max` on the vector of rank values for each input component.


### `Filter`

__Class__: `filter.dfilt` or `[]`

__Default__: `[]`

A filter to be applied to the time-series before computing the rank index.
If empty, no filter will be used.
