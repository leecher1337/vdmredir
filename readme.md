About vdmredir
==============
Starting with Windwos Versions after Windows XP, the NTVDM lost more and
more networking functionality reagarding NetBIOS/LANManager-Support.
I.e., starting with Windows 7, mapping Network drives via plain DOS API
isn't possible anymore. This may have been ue to changes in the SMBV1
protocol implementations.
So i.e. a lot of VDMREDIR-Fucntions got stubbed out which are listed
in [this patch](https://github.com/leecher1337/ntvdmx64/commit/576eafa6c4a55823aee4f5f26285675c95f0eb4b).
However, they cut out more functionality as they would have to due to the
changes made, so I guess, it was another act of lazyness so to not have to
maintain the NTVDM code leaving users with broken NetBIOS-Support.

This patch aims at replacing the vdmredir.dll shipped with Windows 7 or
above with a set of DLLs to restore as much functionality as possible.
So this patch is also suited for the classic 32-bit original Windows NTVDM,
that's the reason why this patch here in a seperate repository, even though
it's normally part of [NTVDMx64](https://github.com/leecher1337/ntvdmx64/).

It should facilitate the building of just the VDMREDIR patch as a standalone
patch in order to use on 32bit Windows.

Requirements
============
 * MinNT repository with NTVDM with latest commits as of Apr 16, 2017 
   (q160765803-minint4-85fac4faadc7 or more specifically 
    MinNT-20170416-85fac4faadc77203db8ddc66af280a75c1b717b0.zip)
 * Windows Driver Kit Version 7.1.0 
   https://www.microsoft.com/en-us/download/details.aspx?id=11800
 * An installed version of 7-zip file manager
   https://www.7-zip.de
 * Windows Server 2003 Sourcecode
   nt5src.7z
   
     OR
   
   Win2K3.7z
   
     OR

   3790src2.cab AND 3790src4.cab
   
Downloaded automatically by build script:
 * NTOSBE-master build environment
 * ntvdmx64 patch 
   https://github.com/leecher1337/ntvdmx64/

 If you are on Windows XP, for downloading via HTTPS:
 * wget.exe
   http://eternallybored.org/misc/wget/1.19.4/32/wget.exe

 You need approx. 4GB of free disk space.

Setup MINNT build environment
=============================
The script should theoretically run from any directory, if directory path
length exceeds 30 characters, a virtual SUBST drive letter is created.
To avoid this step, use a build directory with a very short path name,
i.e. C:\NTVDMBLD

1) Place the files from the requirements section in directory:

   MinNT-20170416-85fac4faadc77203db8ddc66af280a75c1b717b0.zip
   nt5src.7z

2) Now place the scripts from the autobuild directory there:

   autobuild.cmd 
   install.bat 

3) Depending on your OS version and TLS-capabilities, either put supplied

   dwnl.exe

   also there, or, if your system is old (like old Win7 version or
   Win XP, download

   wget.exe

   from link above and place it there.

Run build
=========
Run

  autobuild.cmd 

It will fetch the required .ISOs from Microsoft download server (please keep 
them so that you don't have to download these big files everytime!), fetch 
NTOSBE and the current ntvdmx64 release from github and build in w\ subdirectory.
After build is done, you should find the release-files in the release-subfolder.

Installation
============
Place the files from release-folder on the target machine and run install.bat 
