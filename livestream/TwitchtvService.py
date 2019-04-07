#!/bin/sh
INPUT=$1
avconv   -i $INPUT -s 1280x720  -r 30 \
 -c:a aac  -ab 128k -strict experimental\
 -c:v libx264 -b 3000 -pre libx264-ultrafast  -f flv \
 rtmp://live-3c.justin.tv/app/live_35713130_p7wzjUpzlFTgj0eyAHW3XlBAiDjMWh
