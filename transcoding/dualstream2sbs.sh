#!/bin/sh

#RANGE="-ss 9:05 -t 0:10"

CC=null
CC="curves=psfile=/Users/aldn/c1.acv,eq=contrast=1.15:saturation=1.3"

OVERLAY="[0:v:0]pad=iw*2:ih[l]; \
         [l][0:v:1]overlay=w:0[o]; \
         [o]scale=iw/2:ih[out0]; \
         [out0]$CC[out]"

#OVERLAY="[0:v:0]pad=iw:ih*2[t];\
#         [t][0:v:1]overlay=0:h[out]"

#echo $OVERLAY
ffmpeg -y \
    $RANGE \
    -i "$1" \
    -filter_complex "$OVERLAY" \
    -map "[out]" \
    -map 0:a \
    -c:v libx264 \
    -preset medium \
    -crf 19 \
    -c:a aac -b:a 192k \
    "$1_3d_sbs.mp4"
