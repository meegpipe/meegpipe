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
Namely, we need to retrieve the EEG data files from subjects 1 and 2. In the
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


## Where is the data?

The messages produced by the `somsds_link2rec` command give a clear indication
of what has just happened. The command `somsds_link2rec` has generated
two [symbolic links][symboliclink] under directory:

````
/data1/projects/meegpipe/batman_tut/gherrero/batman
````

that point to two files located under directory:

````
/data1/recordings/batman/subjects
````

You can treat these symbolic links as if they were the actual raw data files.

[symboliclink]: http://en.wikipedia.org/wiki/Symbolic_link

The advantage of using symbolic links instead of simply copying the raw data
to our working directory is that the raw files are very large (almost 30 Gb
each). On the other hand, the size of the symbolic links is negligible. You can
create as many symbolic links as you want. You can also delete them without ever
risking deleting the actual data files that they point to.

Consider the case that we would like to perform two different analyses on the
same set of files. You can use `somsds_link2rec` to keep your two analyses into
two completely self-contained directories (named `analysis1` and `analysis2`):

````bash
mkdir analysis1
somsds_link2rec batman --subject 1,2 --modality eeg --folder analysis1
# ...
# go into analysis1 and perform the first analysis
# ...

mkdir analysis2
somsds_link2rec batman --subject 1,2 --modality eeg --folder analysis2
# ...
# go into analysis2 and perform the second analysis
# ...
````

The `--folder` argument tells `somsds_link2rec` to generate the links into
a directory with a specific name (instead of the default name: `batman`). If
after performing your two analyses you realize that they were useless, you could
just delete them using:

````
rm -rf analysis1
rm -rf analysis2
````


[somsds]: http://www.germangh.com/somsds/


## [Continue to the next step ...][splitting]

[splitting]: ./splitting_raw_data.md
