Git OSX Installer
=================
=================

https://github.com/macadmins/git

This project was forked from https://github.com/timcharper/git_osx_installer/

Report any issues here: https://github.com/macadmins/git/issues


INSTALLATION
============

Step 1 - Install Package
------------------------
Double-click the package in this disk image to install. This installs
git to /usr/local/git, and places symlinks into /usr/local/bin and
/usr/share/man/.

UNINSTALLING
============

Run the uninstall script in /usr/local/git/uninstall.sh

NOTES ABOUT THIS BUILD
============

* Since Mac OS X does not ship with gettext, this build does not
  include gettext support. If popular demand requests (via the git
  issue tracker
  http://code.google.com/p/git-osx-installer/issues/list) the
  installer may bundle gettext in the future to provide localization
  support.

KNOWN ISSUES
============


Git GUI / gitk won't open - complain of missing Tcl / Tk Aqua libraries
-----------------------------------------------------------------------

If you don't already have Tcl/Tk Aqua installed on your computer (most
MacOS X installs have it), you will get this error message. To resolve
it, simply go to the website for Tcl / Tk Aqua and download the latest
version:

http://www.categorifiedcoder.info/tcltk/

If you have an older version of Tcl / Tk Aqua, you'll benefit from
upgrading.

More information:

http://code.google.com/p/git-osx-installer/issues/detail?id=41
