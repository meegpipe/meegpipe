Attribution
========

__NOTE:__ This list is still incomplete. I will shortly add more detailed 
information, including scientific references for some of the software 
tools listed below. 

_meegpipe_ ships the following third-party software (in no particular order):



### AMICA

[AMICA][amica] is an ICA algorithm developed by [Jason Palmer][jason]. 

[amica]: http://sccn.ucsd.edu/~jason/amica_web.html
[jason]: http://sccn.ucsd.edu/~jason/


### eWASOBI, EfICA and MULTICOMBI

These are three BSS algorithms whose implementations have been kindly
provided by [Petr Tichasvky][petr].

[petr]: http://si.utia.cas.cz/Tichavsky.html

### JADE

The implementation of the [JADE][jade] ICA algorithm by the algorithm's
author [Jean-Francois Cardoso][cardoso].

[jade]: http://perso.telecom-paristech.fr/~cardoso/Algo/Jade/jadeR.m
[cardoso]: http://perso.telecom-paristech.fr/~cardoso/

### FastICA

The implementation of the [FastICA][fastica] algorithm by FastICA's author
[Aapo Hyvarinen][aapo].

[aapo]: http://www.cs.helsinki.fi/u/ahyvarin/
[fastica]: http://research.ics.aalto.fi/ica/fastica/

### FMRIB's plug-in for EEGLAB

The version of [FMRIB plug-in][fmrib] bundled with _meegpipe_ includes
some minor modifications by [Johan Van Der Meer][johan]. 

[johan]: http://nl.linkedin.com/pub/johan-van-der-meer/10/554/3a0
[fmrib]: http://www.fmrib.ox.ac.uk/eeglab/fmribplugin/


### LASIP

_meegpipe_ includes some [demo code][lasip] for the 1D Adaptive Scale
Selection filters developed by [Alessandro Foi][foi] and others at 
[Tampere University of Technology][tut], Finland.

[lasip]: http://www.cs.tut.fi/~lasip/1D/
[foi]: http://www.cs.tut.fi/~foi/
[tut]: http://www.tut.fi


### Matlab central code

I have taken quite a few pieces of code from [Matlab Central][mcentral]. 
Note that in some cases I have modified the original source code so I am 
maintaining an independent repository for each of the Matlab Central 
submissions that I list below:

[mcentral]: http://www.mathworks.nl/matlabcentral/

* Jan Simon's [DataHash][datahash]. I maintain a clone of Jan Simon's code
including some minor modifications in a [github repo][external-datahash].

[datahash]: http://www.mathworks.com/matlabcentral/fileexchange/31272
[external-datahash]: https://github.com/germangh/matlab_external_datahash

* Juerg Schwizer's [plot2svg][plot2svg]. A clone of Juerg's original code 
with my own minor modifications is available [here][external-plot2svg].

[external-plot2svg]: https://github.com/germangh/matlab_external_plot2svg
[plot2svg]: http://www.mathworks.nl/matlabcentral/fileexchange/7401-scalable-vector-graphics-svg-export-of-figures


* Andrea Bliss' [rotateticklabel][rotateticklabel].

[rotateticklabel]: http://www.mathworks.nl/matlabcentral/fileexchange/8722-rotate-tick-label


* Rob Campbell's [ShadedErrorBar][shadederrorbar].

[shadederrorbar]: http://www.mathworks.com/matlabcentral/fileexchange/26311

### Remark

[Remark][remark] is developed and maintained by [Kalle Rutanen][kalle], 
Remark implements all the machinery necessary to generate _meegpipe_'s
HTML processing reports. Moreover, the installation instructions for 
the _Pygments_, _Markdown_ and _PIL_ libraries that appear in _meegpipe_'s
documentation have been borrowed from Remark's 
[installation instructions][remark-install]. 

Note that remark itself includes third-party software. Please see 
[Remark's documentation][remark-install] for more information. 

[kalle]: http://kaba.hilvi.org/homepage/
[remark]: http://kaba.hilvi.org/remark/remark.htm
[remark-install]: http://kaba.hilvi.org/remark/installation.htm

### Runica

[runica][runica] is the implementation of the [Infomax][infomax] ICA 
algorithm that is included with [EEGLAB][eeglab].

[eeglab]: http://sccn.ucsd.edu/eeglab/
[runica]: http://sccn.ucsd.edu/eeglab/allfunctions/runica.html
[infomax]: http://en.wikipedia.org/wiki/Infomax



