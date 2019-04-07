#!/bin/bash

usage() {
  printf "Usage: %s video_size pixel_format framerate base_output_filename\n" "$0"
}

# validate num params
if ! (( $# == 4 )); then
  usage
  exit -1
fi

exec >/tmp/pipe_ffmpeg.out 2>&1

echo "cmdline: $@"


ENABLE_AUDIO=0
ENABLE_NVENC=0

OPTIONS="-y -nostats -f rawvideo -video_size $1 -pixel_format $2 -framerate $3 -i /dev/stdin "
#OPTIONS+="-vsync passthrough "

if ENABLE_AUDIO then
    AQUALITY="-b:a 128k"
    OPTIONS+="-thread_queue_size 512 -f pulse -i alsa_output.pci-0000_00_1b.0.analog-stereo.monitor "
    OPTIONS+="-c:a libopus $AQUALITY "
fi

if !$ENABLE_NVENC then
    OPTIONS+="-c:v libx264 -preset superfast -profile:v main -level 4.1 -pix_fmt yuv420p "
    OPTIONS+="-x264opts keyint=60:bframes=2:ref=1 -maxrate 4500k -bufsize 9000k -shortest "
else

    #NVIDIA HW encoding
    #-cq <0..51>
    VQUALITY="-preset slow -profile:v high  -rc vbr -cq 28 -qmin 1 -qmax 28"

    OPTIONS+="-c:v h264_nvenc $VQUALITY "
fi


OUTPUT_NAME=$4_`date +%F_%H_%M_%S`.mkv
OPTIONS+="$OUTPUT_NAME "

echo "ffmpeg options: $OPTIONS"

exec ffmpeg $OPTIONS
