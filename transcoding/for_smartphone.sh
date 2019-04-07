#!/bin/sh

ffmpeg -y \
    -i $1 \
    -vf scale=iw/2:ih/2 \
    -c:v libx264 \
    -preset fast \
    -crf 18 \
    -c:a copy \
    $1_smartphone_gearvr.mp4
