Getting the raw data files
===

The experimental data files from the BATMAN project are managed by the
[somsds][somsds] software. The _somsds_ data management assigns several
meta-data tags to every data file that it manages. It then allows you to
retrieve a set of files by querying _somsds_ for files with specific tag values.
For instance, all experimental files acquired within the BATMAN project have
a _recording_ tag with value set to _batman_.

## Moving to our working directory

Before anything else we will locate ourselves in our main working directory.
Open a shell window and type:

````bash
cd /data1/projects/meegpipe/tut_batman/[username]
````
where `[username]` is your username at the `somerengrid`. In all the examples
below I will use my username (`gherrero`) for illustration purposes.


## Retrieving the experimental data

In this tutorial we are going to work with a subset of the BATMAN dataset.
Namely, we want to retrieve the EEG data files from subjects 1 and 2. In the
shell window type:


````bash
somsds_link2rec batman --subjects 1,2 --modality eeg
````

Note that in the [roadmap][roadmap] of this tutorial we didn't plan any analyses
on the EEG data and yet we are retrieving _EEG_ data files. To keep things
simple, the [somsds][somsds] data management system only assigns one value to
every meta-data tag associated with an experimental data file. In the case of
the BATMAN project, the ECG, ABP, temperature and EEG data are all stored in the
same `.mff` file (produced by [EGI]'s [Netstation] software). When multiple
modalities are stored in a single data file, the `modality` tag of the file
matches the _main_ modality contained in the file. BATMAN's `.mff` files hold 257
EEG channels and 12 additional physiological channels (ABP, ECG, temperature).
Thus it is reasonable to consider that EEG is the main modality of those `.mff`
files.

[roadmap]: ./README.md
[egi]: http://www.egi.com/
[netstation]: http://www.egi.com/index.php?option=com_content&view=article&id=413


After you run the `somsds_link2rec` command above, the following messages will
be displayed in your shell window:

![somsds_link2rec output](./img/somsds_link2rec.png "Output produced by the
somsds_link2rec command")





[somsds]: http://www.germangh.com/somsds/


