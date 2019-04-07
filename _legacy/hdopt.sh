#!/bin/sh
# set hard drive params:
# -I/O mode to 32-bit with sync
# -enable DMA
# -set DMA mode to UltraDMA mode2
# -set standby timeout to 30 minutes

if [ -n $1 ] ; then
    harddisk="hda";
else
    harddisk=$1;
fi
hdparm -c 3 -d1 -X66 -S 241 /dev/${harddisk}
