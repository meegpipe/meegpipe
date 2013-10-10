`ecg_annotate` installation instructions
===

On top of the basic installation steps of [meegpipe][meegpipe], node
[ecg_annotate][ecg_annotate] requires some extra steps to become operational.
Below you can find OS-specific instructions.

[meegpipe]: http://meegpipe.com
[ecg_annotate]: ./README.md

## Common to all OSes

1. Install [Virtual Box][vbox].

[vbox]: https://www.virtualbox.org

2. Download the [virtual appliance][vm] that contains the `ecgpuwave` binaries.

[vm]: http://kasku.org/ecgpuwave.ova

3. Import the virtual appliance `ecgpuwave` that you just downloaded into
Virtual Box (use menu option _File>Import appliance..._).

4. Ensure that Virtual Box's installation directory is in your system's `PATH`
variable. The executable file `VBoxManage` which is part of Virtual Box should
be accessible from MATLAB, i.e. the following MATLAB command should display some
information on the usage of `VBoxManage`:

    ````matlab
    system('VBoxManage');
    `````

## Windows

1. Install [PuTTY][putty].

[putty]: http://www.chiark.greenend.org.uk/~sgtatham/putty/download.html

2. Ensure that PuTTY's installation directory is in your
   [Windows PATH variable.][winPATH]. If this has been done correctly, the
   following MATLAB commands should display usage information on PuTTY's
   utilities `plink` and `pscp`:

    ````matlab
    system('plink');
    system('pscp');
    ````
[winPATH]: http://www.computerhope.com/issues/ch000549.htm


## Linux

1. Install a ssh client, if you don't have one already installed in your system.
   If your system has an ssh client the following MATLAB command should display
   a usage information message:

    ````matlab
    system('ssh');
    ````
    The way you install a ssh client depends on the package manager used by your
    Linux distro. In Debian-like systems you need to run this command from
    a terminal window:

    ````bash
    sudo apt-get install openssh-client
    `````


2. Install [sshpass][sshpass]. The installation process depends on which Linux
   distro you are using. In Debian-like systems:

   ````bash
   sudo apt-get install sshpass
   ````

[sshpass]: http://sourceforge.net/projects/sshpass/


## Mac OS X

Node `ecg_annotate` does not work yet on Mac OS X.
