Optional dependencies
===

The dependencies listed here are not required for _meegpipe_ to work, but they
can considerably enhance _meegpipe_'s functionality.


## Google Chrome (strongly recommended)

_meegpipe_ generates HTML reports with lots of [.svg][svg] graphics
embedded. [Google Chrome][gc] is far superior to other browsers when handling
`.svg` files and thus it is strongly recommended that you install Google
Chrome. 

[svg]: http://en.wikipedia.org/wiki/Scalable_Vector_Graphics
[gc]: https://www.google.com/intl/en/chrome/browser/


## Sun/Oracle grid engine

If [Oracle Grid Engine][oge] (OGE) is installed on your system,
then _meegpipe_ should be able to use it to push your processing jobs to the
grid.  A good overview on the administration of OGE can be found on 
[this presentation][oge-slides] by Daniel Templeton. 


[oge]: http://www.oracle.com/us/products/tools/oracle-grid-engine-075549.html
[oge-install]: http://docs.oracle.com/cd/E19680-01/html/821-1541/ciajejfa.html
[oge-slides]: http://beowulf.rutgers.edu/info-user/pdf/ge_presentation.pdf


## Condor high-throughput computing

If [Condor][condor] is installed on your system then _meegpipe_ will be 
able to use to parallelize the workload produced by _meegpipe_. Condor can 
be used to submit jobs to specialized clusters, to idle computers, to 
the grid, or even to the cloud. If you are using _meegpipe_ on a powerful 
multi-core workstation you can also use Condor to exploit these local 
parallel resources.

[condor]: http://research.cs.wisc.edu/htcondor/

