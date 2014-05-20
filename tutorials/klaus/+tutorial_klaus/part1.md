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

````
% Display (produce a text representation of) a MATLAB vector
myVec = [1 2 3]
disp(myVec)
% Display (produce a text representation of) a physioset
disp(myPhysObj)
````

It may look from the code above that we are using the same `disp()` 
function to display the contents of a vector and to display (a summary of)
the contents of a physioset. However, this is not correct. When running
`disp(myVec)`, MATLAB's built-in `disp()` function is called:

````
% Show me the contents of MATLAB's built-in disp() function
edit disp
````

On the other hand, running `disp(myPhyObj)` will call method `disp()` for 
the `physioset` class:

````
% Show me the contents of method disp() for class physioset
edit physioset.physioset.disp
````


### A physioset that contains real data

An empty _physioset_ like the one that we built above is useless. For a 
_physioset_ to make any sense it should be based on the contents of a 
experimental recording. The code below will create a physioset