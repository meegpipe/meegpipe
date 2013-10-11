`spt` package
====


The `spt` package contains classes and functions for performing spatial
transformations on multi-dimensional point-sets. It also includes
automated component selection criteria to support spatial filtering
operations. See the table below for an overview of the main API components
included in this repository:

Component                   |  Description
-------------------         |  -------------
[spt.bss][spt-bss]          |  [Blind Source Separation][wiki-bss] algorithms
[spt.pca][spt-pca]          |  [Principal Component Analysis][wiki-pca]
[spt.criterion][spt-crit]   |  Component selection criteria
[spt.plotter][spt-plot]     |  Plot spatial transformations

[wiki-pca]: https://en.wikipedia.org/wiki/Principal_component_analysis
[wiki-bss]: http://en.wikipedia.org/wiki/Blind_signal_separation

[spt-bss]: ./+bss/README.md
[spt-pca]: ./+pca/README.md
[spt-crit]: ./+criterion/README.md
[spt-plot]: ./+plotter/README.md


A simple class diagram illustrating the hierarchy of spatial transformation
classes within package `spt` is shown below. Note that the diagram does not
cover the hierarchy of component selection criteria classes (contained in
package [sptc.criterion][spt-crit]), nor the hierarchy of the spatial
tranformation plotting classes (contained in package [spt.plotter][spt-plot]).

![spt class hierarchy](spt-class-hierarchy.png "Class hierarchy within package spt")
