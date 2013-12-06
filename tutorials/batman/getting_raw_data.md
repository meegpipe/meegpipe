Getting the raw data files
===

The experimental data files from the BATMAN project are managed by the
[somsds][somsds] software. The _somsds_ data management assigns several
meta-data tags to every data file that it manages. It then allows you to
retrieve a set of files by querying _somsds_ for files with specific tag values.

For instance, all experimental files acquired within the BATMAN project have
a _recording_ tag with value set to _batman_. If we wanted to retrieve all BATMAN
we could open a shell window and type:

````bash
somsds_link2rec batman
````



[somsds]: http://www.germangh.com/somsds/


