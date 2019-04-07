#!/bin/sh

FILE=$1
START=$2
DURATION=$3
# NOAUDIO=-an
NOAUDIO=
ffmpeg  -ss $START -i $FILE -t $DURATION -vf scale=w=-2:h=720 $NOAUDIO -c:v libx264 -preset fast -crf 17 cut.mp4
