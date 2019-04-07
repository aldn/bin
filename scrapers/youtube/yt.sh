#!/bin/sh

if [[ $# -lt 1 ]]
then
    echo "usage: $0 [YOUTUBE LINK]"
    exit 1
fi

echo "downloading ...."
cd ~/Downloads && /usr/local/bin/youtube-dl --merge-output-format mp4 "$1"

if [[ $? -eq 0 ]]
then
    echo "converting to mp4 ...."
    /usr/local/bin/ffmpeg -i "$1" -c:v copy -c:a aac -b:a 256k "${1%.*}_aac.mp4"
    exit 0
else
    #echo "failed to download!"
    exit 1
fi

