Retrieve the raw data files
===

__NOTE__: This step is only relevant if you are following this tutorial from a node
of _somerengrid_, the private computing grid of the [Sleep & Cognition][sc] team
of the [Netherlands Institute for Neuroscience (NIN)][nin]. At this point, the raw
data files are not publicly available but they will be, eventually. If you are
working at the NIN and are interested in getting access to the raw data, please
contact [German Gomez-Herrero][ggh].

[nin]: http://www.nin.knaw.nl
[sc]: http://www.nin.knaw.nl/research_groups/van_someren_group
[ggh]: http://germangh.com

The experimental data files from the BATMAN project are managed by a
specialized software tool: [the somsds data management system][somsds].
This software stores meta-data associated to the experimental data files that it
manages. It then allows you to retrieve a set of files by querying _somsds_
using such meta-data. For instance, all experimental files acquired within
the BATMAN project have a meta-data tag named _recording_, which is set to
the value _batman_.

## Moving to our working directory

Before anything else we will locate ourselves in our main working directory.
Open a shell window and type:

````bash
cd /data1/projects/meegpipe/batman_tut/[username]
````
where `[username]` is your username at the `somerengrid`. In all the examples
below I will use my username (`gherrero`) for illustration purposes.


## Retrieving the experimental data

In this tutorial we are going to consider only a subset of the BATMAN dataset.
Namely, we want to retrieve the EEG data files from subjects 1 and 2. In a
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
matches the _main_ modality that is contained in the file. BATMAN's `.mff` files
hold 257 EEG channels and 12 additional physiological channels (ABP, ECG,
temperature). Thus the reason for considering `eeg` as the main modality.

[roadmap]: ./README.md
[egi]: http://www.egi.com/
[netstation]: http://www.egi.com/index.php?option=com_content&view=article&id=413

The `somsds_link2rec` command will generate the following messages:

![somsds_link2rec output](./img/somsds_link2rec.png "Output produced by the
somsds_link2rec command")


Hopefully, these messages give you an indication of what has just happened.
They are telling you that two [symbolic links][symboliclink] have been
generated under directory:

````
/data1/projects/meegpipe/batman_tut/gherrero/batman
````
[symboliclink]: http://en.wikipedia.org/wiki/Symbolic_link

From now on you can treat these symbolic links as if they were the raw data
files you are interesting in processing. The advantage of using symbolic links
instead of simply copying the raw data to our working directory is that the raw
files are very large (about 30 Gb each). On the other hand, the size of the
symbolic links is negligible. You can create as many symbolic links as you want.
You can also delete them without ever risking deleting the actual data files
that they point to.

Consider the case that we would like to perform two different analyses on the
same set of files. You can use `somsds_link2rec` to keep your two analyses into
two completely self-contained directories (named e.g. `analysis1` and
`analysis2`):

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
a specific directory. The default behavior is to generate them under a
subdirectory (named as the `recording` name) within your current directory.

If after performing your two analyses you decide to discard them, then you could
simply delete the containing directories:

````
rm -rf analysis1
rm -rf analysis2
````
[somsds]: http://www.germangh.com/somsds/


It is good practice that you always keep your analysis results fully
self-contained. That means that if folder `analysis1` should not contain only
the results of your analysis but _also the raw data_ (or, in our case, symbolic
links to the raw data).


## [Continue to the next step ...][splitting]

[splitting]: ./splitting_raw_data.md
