`ecg_annotate` - Annotate ECG heartbeats
===

The `ecg_annotate` node detects QRS complexes and annotates heartbeats
using [ecgpuwave][ecgpuwave]. This node is actually a wrapper to the public
`ecgpuwave` implementation in Fortran 77 by [Pablo Laguna][laguna] and others.

Additionally, the `ecg_annotate` node computes heart rate variability features
based on the annotations produced by `ecgpuwave`. This is done using the
[HRV Toolkit][hrv_toolkit] available at [physionet.org][physionet]. The HRV
features are stored in a log file (`features.txt`) contained within the node's
report directory.

[hrv_toolkit]: http://physionet.org/tutorials/hrv-toolkit/
[physionet]: http://physionet.org/

## Dependencies

Compiling Fortran 77 code in modern Linux distros and modern versions of
[Cygwin][cygwin] can be remarkably difficult. I have got around this problem by
compiling the original implementation of `ecgpuwave` by Pablo Laguna in a
[Virtual Machine][vbox] running an ancient [Debian 4.0][debian4] linux distro.
This VM needs to be in the same network as the machine running node
`ecg_annotate`. If you are working at `somerengrid` (the private computing grid
used by our [research group][sc]) then you don't need to worry about this and
everything should work out of the box. Otherwise you will need to perform some
[additional installation steps][install].

[install]: ./installation.md
[sc]: http://www.nin.knaw.nl/research_groups/van_someren_group/
[vbox]: https://www.virtualbox.org/
[debian4]: http://www.debian.org/releases/etch/debian-installer/
[ecgpuwave-install]: http://www.physionet.org/physiotools/ecgpuwave/src/INSTALL
[cygwin]: http://www.cygwin.com/
[ecgpuwave]: http://www.physionet.org/physiotools/ecgpuwave/
[laguna]: http://diec.unizar.es/~laguna/personal/

## Usage synopsis:

````matlab
import meegpipe.*;
obj = node.ecg_annotate.new('key', value, ...)
run(obj, data);
````

where `data` is a [physioset][physioset] object.

[physioset]: https://github.com/germangh/matlab_physioset/blob/master/%2Bphysioset/%40physioset/README.md


## Construction arguments

The `qrs_detect` node admits all the key/value pairs admitted by the
[abstract_node][abstract-node] class. For configuration options specific to this
node class see the documentation of the helper [config][config] class.

[abstract-node]: ../@abstract_node/README.md
[config]: ./config.md


## Methods

See the documentation of the [node API documentation][node].

[node]: ../


