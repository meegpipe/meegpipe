Part 1: working with physiosets
=====




## Creating a physioset


### An empty (useless) physioset

You can create an empty [physioset][physioset] object using the 
corresponding [class constructor][constructor]:

[physioset]: ../../../+physioset/@physioset/README.md
[constructor]: http://en.wikipedia.org/wiki/Constructor_(object-oriented_programming)

````matlab
myPhysObj = physioset.physioset
````

which will produce the following output:

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

The `physioset.` is necessary because the _physioset_ class definition as 
well as other related classes and functions are contained within the 
[physioset package][physiosetpkg]. If you don't know what a MATLAB package
is, please take a look at the [documentation][matlabpkg]. An equivalent 
way to create an empty _physioset_ is:

````matlab
% Tell MATLAB that when we write physioset, we mean: physioset.physioset
import physioset.physioset 
myPhysObj = physioset
````

[matlabpkg]: http://www.mathworks.nl/help/matlab/matlab_oop/scoping-classes-with-packages.html
[physiosetpkg]: ../../../+physioset


### A physioset that contains real data

