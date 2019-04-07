#!/bin/sh

START=00:00:02.0
DURATION=00:40:55.0

ffmpeg  -ss $START -i $1 -c copy -t $DURATION cut_$1
