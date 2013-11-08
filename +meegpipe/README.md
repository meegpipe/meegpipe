meegpipe API documentation
========

The components of the _meegpipe_ [API][api] are organized in various
[MATLAB packages][matlab-pkg]. The table below summarizes 
the major API components.

[api]: http://en.wikipedia.org/wiki/Application_programming_interface
[matlab-pkg]: http://www.mathworks.nl/help/matlab/matlab_oop/scoping-classes-with-packages.html

MATLAB package    | What is there?                                                  
--------------    | --------------------                                            
[+meegpipe/+node][meegpipe.node]   		 | Processing nodes and pipelines                                   
[+physioset][physioset]            		 | Data structure for physiological datasets 
[+physioset/+import][physioset.import]   | Import data from various file formats 	          
[+physioset/+event][physioset.event]     | Events for physiosets                     
[+sensors][sensors]              		 | Data sensors    
[+filter][filter]		  		   		 | Digital filters                           
[+spt][spt] 	  				   		 | Spatial transforms                        
[+spt/+bss][spt.bss]         	   		 | [Blind Source Separation][bss] algorithms                     
[+spt/+criterion][spt.criterion]   		 | Criteria for selecting spatial components                           
[+pset][pset]                            | Low level data structure for high-dimensional point-sets


[bss]: http://en.wikipedia.org/wiki/Blind_source_separation

[meegpipe.node]: ./+node/README.md
[filter]: ../+filter/README.md
[spt]: ../+spt/README.md
[spt.bss]: ../+spt/+bss/README.md
[spt.criterion]: ../+spt/+criterion/README.md
[physioset]: ../+physioset/README.md
[physioset.import]:  ../+physioset/+import/README.md
[physioset.event]: ../+physioset/+event/README.md
[sensors]: ../+sensors/README.md
[pset]: ../+pset/README.md

The _meegpipe_'s API follows the [object oriented (OO)][oo-programming] 
programming paradigm. If you are not familiar with OO concepts like
_class_, _object_ or _interface_, you may want to read some
[backbround material][oo-concepts] before going any further. If you have
never used the OO paradigm in MATLAB, you may also want to read some
documentation on the specifics of [MATLAB's OO programming][matlab-oo].

[oo-concepts]: http://docs.oracle.com/javase/tutorial/java/concepts/

The most important component of the API is the `node` interface. The 
definitions and implementations of all `node` classes (i.e. of all classes
that implement the `node` interface) are found in package 
[+meegpipe/+node][meegpipe.node]. All other components of `meegpipe` may be
considered as building blocks for the tools that can be found within the 
[+meegpipe/+node][meegpipe.node] package.

[oo-programming]: http://en.wikipedia.org/wiki/Object-oriented_programming
[matlab-oo]: http://www.mathworks.nl/help/matlab/object-oriented-programming.html

