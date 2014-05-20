Part 1: working with physiosets
=====

If you are not familiar with Object Oriented (OO) programming concepts like
_class_, _object_ or _interface_, you may want to read some
[background material][oo-concepts] before going any further. You may also
 want to read some documentation on the specifics of 
[MATLAB's OO programming][matlab-oo].

[oo-concepts]: http://docs.oracle.com/javase/tutorial/java/concepts/
[oo-programming]: http://en.wikipedia.org/wiki/Object-oriented_programming
[matlab-oo]: http://www.mathworks.nl/help/matlab/object-oriented-programming.html


## Creating a physioset


### An empty (useless) physioset

You can create an empty [physioset][physioset] object using the 
corresponding [class constructor][constructor]:

[physioset]: ../../../+physioset/@physioset/README.md
[constructor]: http://en.wikipedia.org/wiki/Constructor_(object-oriented_programming)

````matlab
myPhysObj = physioset.physioset
````

The `physioset.` is necessary because the _physioset_ class definition is 
contained within the [physioset package][physiosetpkg]. If you don't know
 what a MATLAB package is, please take a look at the 
[documentation][matlabpkg]. An equivalent way to create an empty
 _physioset_ is:

````matlab
% Tell MATLAB that when we write physioset, we mean: physioset.physioset
import physioset.physioset 
myPhysObj = physioset
````

[matlabpkg]: http://www.mathworks.nl/help/matlab/matlab_oop/scoping-classes-with-packages.html
[physiosetpkg]: ../../../+physioset

MATLAB will produce the following output after running any of the two code
 snippets above:

````matlab
myPhysObj = 

handle
Package: physioset


                Name : physioset
               Event : []
             Sensors : 0 sensors.dummy; 
        SamplingRate : 250 Hz
             Samples : 0
            Channels : 0
           StartTime : 20-05-2014 13:28:58:230
        Equalization : n/a
           Reference : raw

Meta properties:
````

What you see above is just the result of calling function `disp()` on our 
physioset:

````matlab
% Display (produce a text representation of) a MATLAB vector
myVec = [1 2 3]
disp(myVec)
% Display (produce a text representation of) a physioset object
disp(myPhysObj)
````

It may look from the code above that we are using the same `disp()` 
function to display the contents of a vector and to display (a summary of)
the contents of a physioset. However, this is not correct. When running
`disp(myVec)`, MATLAB's built-in `disp()` function is called:

````matlab
% Show me the contents of MATLAB's built-in disp() function
edit disp
````

On the other hand, running `disp(myPhyObj)` will call method `disp()` for 
the `physioset` class:

````matlab
% Show me the contents of method disp() for class physioset
edit physioset.physioset.disp
````


### A physioset that contains real data

An empty _physioset_ like the one that we built above is useless. For a 
_physioset_ to make any sense it should be based on the contents of a 
experimental recording. The code below will create a physioset based on 
the contents of an EEG recording in EEGLAB's format:

````matlab
% Download and unzip the sample recording (you have done this already!)
unzip('https://dl.dropboxusercontent.com/u/4479286/meegpipe/NBT.S0021.090205.EOR1.zip')

% Create an importer object that knows how to read EEGLAB files
myImporter = physioset.import.eeglab;

% Use method import() of the importer object to create a physioset object 
% based on the contents of the file
myPhysObj = import(myImporter, 'NBT.S0021.090205.EOR1.set')
````

Since we did not terminate with a `;` the last command above, MATLAB will
display the contents of the newly created _physioset_:

````matlab
>> myPhysObj

myPhysObj = 

handle
Package: physioset


                Name : NBT.S0021.090205.EOR1
               Event : []
             Sensors : 129 sensors.eeg; 
        SamplingRate : 200 Hz
             Samples : 60000 (300.0 seconds), 0 bad samples (0.0%)
            Channels : 129, 0 bad channels (0.0%)
           StartTime : 20-05-2014 14:05:44:571
        Equalization : no
           Reference : raw

Meta properties:

    eeglab: [1x1 struct]

````

You may have noticed that when the _physioset_ object `myPhysObj` was 
created, a file called `NBT.S0021.090205.EOR1.pset` was created in your 
current working directory. It is in that file where the EEG data values 
are actually stored and not in the `myPhysObj` variable that you have 
in your MATLAB workspace and that is intended to hold only meta-data such 
as sensor information and events. Indeed, `myPhysObj` occuppies only 
112 bytes in MATLAB's working memory, which is far too little to contain
60000 samples of 128 EEG channels:

````matlab
>> whos
  Name              Size               Bytes  Class                      Attributes
                              
  myImporter        1x1                  311  physioset.import.eeglab              
  myPhysObj       129x60000              112  physioset.physioset                  

````

Whenever you create a _physioset_ object, a corresponding `pset` file will 
be created to hold the values of the time-series contained in the 
_physioset_. In this way, _meegpipe_ can handle very large data files 
without running into memory problems, provided of course that you have 
enough disk space. 

## Accessing physioset data

Our _physioset_ object `myPhysObj` gives as access to the EEG time-series 
and all related meta-data (events, sensors information, etc). You can 
access the EEG data values in the same way as you would access elements in 
a MATLAB matrix. For instance, you can get the 5 first values of channel 
number 15 as follows:

````matlab
eegValues = myPhysObj(15, 1:5)
````

The code above will create a MATLAB vector with 5 elements called 
`eegValues` and will display its contents:

````matlab
eegValues =

 -162.4577 -184.7542  120.4011   77.2734 -213.7123
````matlab


## Understanding physiosets

Since a _physioset_ object can contain a huge amount of data any operation 
that you perform on a physioset is run in-
