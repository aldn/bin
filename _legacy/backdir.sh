#!/bin/sh
[ "$1" = "" ] && echo "error: no directory specified!" && exit 1
[ -f $1/version ] && . $1/version && VERSION="$VERSION-"

rar a -m5 $1-$VERSION`date +%Y%m%d`.rar $1
