#!/bin/sh

#ffmpeg -i $1 -c:v libx264 -crf 12 -b:v 500K $1.mp4
ffmpeg -i $1 -c:v libvpx -qmin 4 -qmax 20  -b:v 1M  $1.webm
