Part 1: exploring your data
=====




## Creating a physioset

You can create an empty [physioset][physioset] object using the 
corresponding [class constructor][constructor]:

[constructor]: http://en.wikipedia.org/wiki/Constructor_(object-oriented_programming)

````matlab
myPhysObj = physioset.physioset
````

The `physioset.` is necessary because the _physioset_ class definition as 
well as other related classes and functions are contained within the  
[physioset package][physiosetpkg]. If you don't know what a MATLAB package
is, please take a look at the [documentation][matlabpkg].

[matlabpkg]: http://www.mathworks.nl/help/matlab/matlab_oop/scoping-classes-with-packages.html
[physiosetpkg]: ../../../+physioset
