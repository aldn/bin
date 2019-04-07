#!/bin/sh

# execute this from project's top-level directory
# to do 'make install' and build the .tgz package at once

package=$(basename $(pwd))
curdir=$(pwd)
packagename=$curdir/${package}-i686-1.tgz
# creates virtual root dir
tmpdir=$(mktemp -d)
# change permissions of virtual root to resemble those of real root
chmod 755 $tmpdir
echo + installing to $tmpdir
make DESTDIR=$tmpdir install
cd $tmpdir
echo + stripping files...
# locate files with execute bit(s) set
find -perm +111 -and ! -type d | xargs strip
makepkg -l y -c n $packagename
echo + package saved as $packagename
echo + removing temporary directory $tmpdir ...
if [ $tmpdir != "/" ]; then
	rm -Rf $tmpdir
fi
