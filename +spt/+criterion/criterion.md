`criterion` interface
===

## Interface methods


### `select`

Selects spatio-temporal components according to certain criterion.


    [sel, rank] = select(obj, spt, ts, ev, rep, raw, ...)


Where:

`spt` is a [spt.spt][spt] object

`ts` is a `KxM` numeric matrix (or [pset][pset] object)

`ev` is an array of [event][event] objects

`rep` is a [report][report] object

`raw` is a [physioset][physioset] object

[spt]: ../spt.md
[pset]: https://github.com/germangh/matlab_pset/tree/master/%2Bpset/%40pset/pset.md
[event]: https://github.com/germangh/matlab_physioset/tree/master/%2Bphysioset/%2Bevent/%40event/event.md
[report]: https://github.com/germangh/matlab_report/tree/master/%2Breport
[physioset]: https://github.com/germangh/matlab_physioset/tree/master/%2Bphysioset/%40physioset/physioset.md


### `not`

Invert a component selection criterion

    obj = not(obj)


### `negated`

Test whether a criterion has been previously negated (inverted)

    bool = negated(obj)

Where

`bool` is a logical scalar. `bool` is true if `obj` has been neated and it is
`false` otherwise.

