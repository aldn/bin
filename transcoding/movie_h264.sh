#!/bin/sh

CRF=19
PRESET=slow

O=
O+="-i $1 "
O+="-vf bwdif=mode=1 "
O+="-c:v libx264 "
O+="-preset $PRESET "
O+="-crf $CRF "
O+="-c:a copy "

ffmpeg -y $O $1__.mp4
