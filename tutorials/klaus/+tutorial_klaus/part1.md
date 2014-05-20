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
enough disk space. You can find out what disk file corresponds to a given
dataset using method `get_datafile()`:

````matlab
get_datafile(myPhysObj)

ans =

C:\workdir\NBT.S0021.090205.EOR1.pset
````

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

Meta-data on sensors, events, etc. can also be accessed and modified using 
appropriate methods. For more information, see the 
[documentation][physioset-api].

[physioset-api]: ../../../+physioset/README.md


## Understanding physiosets


### Aliases

The following code snippet illustrates a crucial characteristic of 
_physioset_ objects that can be quite counterintuitive at first:

````matlab
% myPhysObj contains our EEG data
% Let's make sure that the first data channel is not filled with zeros
assert(~all(myPhysObj(1,:) == 0));

% Now let's make a copy of our physioset:
myPhysObjCopy = myPhysObj;

% Lets's set to zeros the first channel of the copied physioset
myPhysObjCopy(1,:) = 0;
assert(all(myPhysObjCopy(1,:) == 0));

% This may be surprising ...
assert(all(myPhysObj(1,:) == 0));
````

Conclusion: `myPhysObj` and `myPhysObj2` are just _aliases_ of the 
same underlying physioset. This is contrary to the behavior of 
the `=` operator for MATLAB's built-in types, which indeed creates two 
independent copies (not aliases) of the same underlying data. 

If you want to create two independent copies of a _physioset_ then you 
need to be explicit about it:

````matlab
% myPhysObj contains our EEG data
% Let's make sure that the first data channel is not filled with zeros
assert(~all(myPhysObj(1,:) == 0));

% Now let's make a REAL copy of our physioset:
myPhysObjCopy = copy(myPhysObj);

% Lets's set to zeros the first channel of the copied physioset
myPhysObjCopy(1,:) = 0;
assert(all(myPhysObjCopy(1,:) == 0));

% This assertion will now fail
assert(all(myPhysObj(1,:) == 0));
````

If you run the code snippet above line by line you will notice that 
command `myPhysObjCopy = copy(myPhysObj)` informs you that the disk file 
that holds the _physioset_ data values is being copied. Indeed, your
 current directory should now contain two `.pset` files like (the 
second file name will differ in your case):

````
NBT.S0021.090205.EOR1.pset
session_1\20140520T152506_a26da.pset
````

You may have also noticed a message saying that a new session (_session1_) 
has been created. Command `myPhysObjCopy = copy(myPhysObj)` requires the
 creation of a new _physioset_ object and thus _meegpipe_ needs 
to produce a suitable name for the corresponding disk file.  
In the absence of more information, _meegpipe_ decides to use a 
semi-random name and place it under a directory called `session_1`. In this
 way you can easily identify files that are produced by meegpipe and that
you may want to remove when you are done with your exploratory analysis. 


### Sessions are persistent

A minor detail is that sessions are persistent so that if you now create 
a new _physioset_ based on a MATLAB matrix:

````matlab
myNewPhysObj = import(physioset.import.matrix, rand(3,1000));
````

Then a new file will be created under directory `session_1`. In my case 
my current directory now looks like this:

````
NBT.S0021.090205.EOR1.pset
session_1\20140520T152506_a26da.pset
session_1\20140520T153908_bdff0.pset
````

You can explicity clear a session like this:

````matlab
clear session
````

so that now the following command will lead to the creation of a new 
session (since it cannot reuse the one we just erased):


````matlab
myNewPhysObj2 = import(physioset.import.matrix, rand(3,1000));
````

Now my current directory looks like this:

````
NBT.S0021.090205.EOR1.pset
session_1\20140520T152506_a26da.pset
session_1\20140520T153908_bdff0.pset
session_2\20140520T154214_6782f.pset
````


### physiosets are temporary by default

By default the disk file associated with a _physioset_ object will exist 
only for as long as there is at least one alias of that _physioset_ in 
the MATLAB workspace. See: 

````matlab
clear all;
````

The command above will not only clear your MATLAB workspace but will also
delete all the `.pset` files that were created as a result of our 
experiments above. That is, both your current directory and the `session_1`
and `session_2` directories should now be empty. Let's see how this works
in more detail:

````matlab
% Let's create a random physioset
obj = import(physioset.import.matrix, rand(2,1000));

% Let's create an alias
obj2 = obj;

% Realize that both obj2 and obj are aliases of the same physioset
assert(strcmp(get_datafile(obj), get_datafile(obj2)));

% Let's delete one of the aliases 
clear obj;

% Notice that the .pset file has not been deleted
dataFile = get_datafile(obj2);
assert(exist(dataFile, 'file') > 0);

% Let's delete the second alias
clear obj2;

% Now the associated .pset file is automatically deleted because there 
% are no remaining references to it in MATLAB's workspace
assert(~exist(dataFile, 'file'));
````


### Storing and retrieving physiosets

Let's import again the sample EEG dataset:

````matlab
% Start with a clean workspace
clear all;

% Import the sample EEG dataset
data = import(physioset.import.eeglab, 'NBT.S0021.090205.EOR1.set');
````

Let's perform a simple modification, such as zeroing out the first data 
channel:

````matlab
data(1,:) = 0;
````

If we would now clear the MATLAB workspace (or if we would quit MATLAB), 
the disk file associated with `data` (file `NBT.S0021.090205.EOR1.pset`)
 would be automatically deleted and therefore our modified _physioset_
object would be lost forever. We can prevent that by _saving_ the 
_physioset_ using the `save()` method:

````matlab
save(data);
````

A side effect of the command above is the creation of a `.pseth` file so 
that your current working directory now looks like this:

````
NBT.S0021.090205.EOR1.set
NBT.S0021.090205.EOR1.fdt
NBT.S0021.090205.EOR1.pset
NBT.S0021.090205.EOR1.pseth
````

That `.pseth` file is used to stored the meta-data associated with your 
_physioset_. As you already know, the `.pset` file stores the EEG 
measurements. After saving our _physioset_ using `save()` we can safely
clear our MATLAB workspace:

````matlab
clear all;
````

Then we can retrieve again our _physioset_ using the `pset.load` function:

````matlab
% We need to load only the .pseth file. Not the .pset!
retrievedData = pset.load('NBT.S0021.090205.EOR1.pseth');

assert(all(retrievedData(1,:)==0));
````
