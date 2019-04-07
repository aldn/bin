#!/bin/sh

# Invoke RPM to find out:
# 1) which package some file ($1) belongs to;
# 2) display file list of that package

FILE=$1

# print invitation
echo "
WhichRPM: finds installed RPM by its file and shows the contents
Written by Alex Dounaevsky <[CRow in @Ktion]>. 2002"

if [ -z $FILE ]; then
	echo "Usage: $0 file_in_your_path"
	exit
fi

# get full path of file
FULLPATH=`which $FILE`
# determine package the file belongs to
PACKAGE=`rpm -q -f $FULLPATH`
# display it's contents
echo '-------------------------------------------------------------'
echo $PACKAGE
echo '-------------------------------------------------------------'
rpm -q -l $PACKAGE
