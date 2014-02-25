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

Open a shell window and type:

````bash
WORK_DIR = '/data1/projects/batman/analysis/eeg-cleaning'
cd $WORK_DIR
````

## Retrieving the experimental data

In the next step of this tutorial we will learn that we can also retrieve the
data from MATLAB. For illustration purposes we will retrieve them here from the
terminal:


````bash
somsds_link2rec batman --subjects 1..10 --modality eeg --file_ext .pset,.pseth
````

Notice that we request only those files with `.pset` or `.pseth`
extensions. Such `.pset/.pseth` files are the result of splitting the
original `.mff` files into single-sub-block files. See the explanations in a
[previous tutorial][batman-tut] for more information on how the splitting was
performed.

[batman-tut]: ../batman/splitting_raw_data.md

[egi]: http://www.egi.com/
[netstation]: http://www.egi.com/index.php?option=com_content&view=article&id=413

The `somsds_link2rec` command will generate the following messages:

![somsds_link2rec output](./img/somsds_link2rec.png "Output produced by the
somsds_link2rec command")

Hopefully, these messages give you an indication of what has just happened.
They are telling you that two [symbolic links][symboliclink] have been
generated under your `$WORK_DIR` directory:

[symboliclink]: http://en.wikipedia.org/wiki/Symbolic_link

From now on you can treat these symbolic links as if they were the raw data
files you are interesting in processing. The advantage of using symbolic links
instead of simply copying the raw data to our working directory is that the raw
files can be very large. On the other hand, the size of the
symbolic links is negligible. You can create as many symbolic links as you want.
You can also delete them without ever risking deleting the actual data files
that they point to.


## [Continue to the next step ...][pipeline-definition]

[pipeline-definition]: ./pipeline_definition.md
