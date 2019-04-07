#!/bin/sh
FILE=Screenshot-`date +%F-%H%M%S`
echo screendump /tmp/$FILE.ppm | socat - UNIX-CONNECT:monitor
sleep 0.5
convert /tmp/$FILE.ppm $FILE.png
rm /tmp/$FILE.ppm
