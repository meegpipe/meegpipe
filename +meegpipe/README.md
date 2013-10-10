meegpipe API documentation
========

The components of the _meegpipe_ [API][api] are organized in various
[MATLAB packages][matlab-pkg], each of which typically belongs to a 
separate [code repository][wiki-revcontrol]. The table below summarizes 
the major API components, roughly sorted from higher to lower
level components:

[api]: http://en.wikipedia.org/wiki/Application_programming_interface
[wiki-revcontrol]: http://en.wikipedia.org/wiki/Source_control
[matlab-pkg]: http://www.mathworks.nl/help/matlab/matlab_oop/scoping-classes-with-packages.html
[ica]: http://en.wikipedia.org/wiki/Independent_component_analysis

MATLAB package    | What is there?                                                   | Git repository       |
--------------    | --------------------                                             | ----------------
[+meegpipe/+node][meegpipe.node]   		 | Processing nodes and pipelines            | http://github.com/germangh/meegpipe
[+somsds][matlab-somsds]                 | Data management*                          | http://github.com/germangh/matlab_somsds
[+filter][filter]		  		   		 | Digital filters                           | http://github.com/germangh/matlab_filter
[+spt][spt] 	  				   		 | Spatial transforms                        | http://github.com/germangh/matlab_spt
[+spt/+bss][spt.bss]         	   		 | [ICA][ica] algorithms                     | http://github.com/germangh/matlab_spt
[+spt/+criterion][spt.criterion]   		 | Criteria for selecting spatial components |  http://github.com/germangh/matlab_spt
[+physioset][physioset]            		 | Data structure for physiological datasets | http://github.com/germangh/matlab_physioset
[+physioset/+import][physioset.import]   | Import data from various file formats 	 | http://github.com/germangh/matlab_physioset
[+physioset/+plotter][physioset.plotter] | Classes for plotting physiosets           | http://github.com/germangh/matlab_physioset
[+physioset/+event][physioset.event]     | Events for physiosets                     | http://github.com/germangh/matlab_physioset
[+sensors][sensors]              		 | Data sensors                              | http://github.com/germangh/matlab_sensors
[+pset][pset]                            | Low level data structure for high-dimensional point-sets | http://github.com/germangh/matlab_pset

__*__ Note that the [+somsds][matlab-somsds] package will be operational
only if the [somsds][somsds] Perl module has been installed in your system, 
and a suitable database has been initialized. This will be the case if you 
are using _meegpipe_ at the _somerengrid_.

[somsds]: https://github.com/germangh/somsds
[matlab-somsds]: https://github.com/germangh/matlab_somsds
[meegpipe.node]: ./+node
[filter]: https://github.com/germangh/matlab_filter
[spt]: https://github.com/germangh/matlab_spt
[spt.bss]: https://github.com/germangh/matlab_spt/tree/master/%2Bspt/%2Bbss
[spt.criterion]: https://github.com/germangh/matlab_spt/tree/master/%2Bspt/%2Bcriterion
[physioset]: https://github.com/germangh/matlab_physioset
[physioset.import]:  https://github.com/germangh/matlab_physioset/tree/master/%2Bphysioset/%2Bimport
[physioset.plotter]: https://github.com/germangh/matlab_physioset/tree/master/%2Bphysioset/%2Bplotter
[physioset.event]: https://github.com/germangh/matlab_physioset/tree/master/%2Bphysioset/%2Bevent
[sensors]: https://github.com/germangh/matlab_physioset/tree/master/%2Bphysioset/%2Bsensors
[pset]: https://github.com/germangh/matlab_pset/tree/master/%2Bpset

The _meegpipe_'s API follows the [object oriented (OO)][oo-programming] 
programming paradigm. If you are not familiar with OO concepts like
_class_, _object_ or _interface_, you may want to read some
[backbround material][oo-matlab] before reading this documentation. The
most important component of the API is the `node` interface. Simply put, an
interface is just a list of functions that must be defined for every class
that inherits (or implements) the interface. Such list of functions is
provided in an _interface definition file_, which is just a standard 
[MATLAB class definition file][matlab-classdef] that defines only
[abstract methods][abstract-methods].

[abstract-methods]: http://www.mathworks.nl/help/matlab/matlab_oop/abstract-classes-and-interfaces.html
[matlab-classdef]: http://www.mathworks.nl/help/matlab/matlab_oop/class-definition.html

The definitions and implementations of all `node` classes (i.e. of all classes
that implement the `node` interface) are found in package [+meegpipe/+node][meegpipe.node]. 
More information regarding the construction and use of processing nodes 
can be found in the documentation of the [+meegpipe/+node][meegpipe.node] 
package.

[oo-programming]: http://en.wikipedia.org/wiki/Object-oriented_programming
[oo-matlab]: http://www.mathworks.nl/company/newsletters/articles/introduction-to-object-oriented-programming-in-matlab.html
[node-ifc]: ./+node/node.m
