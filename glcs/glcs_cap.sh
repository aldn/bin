#!/bin/bash
#
# capture.sh -- example: glc environment variables and usage
# Copyright (C) 2007 Pyry Haulos
# For conditions of distribution and use, see copyright notice in glc.h

# picture stream fps
export GLC_FPS=60

# scale pictures
export GLC_SCALE=1.0

# capture audio
export GLC_AUDIO=0

# captured pictures and audio buffer size, in MiB
export GLC_UNCOMPRESSED_BUFFER_SIZE=25

# unscaled pictures buffer size, in MiB
export GLC_UNSCALED_BUFFER_SIZE=25

# compressed data buffer size, in MiB
export GLC_COMPRESSED_BUFFER_SIZE=50

# take picture at glFinish(), compiz needs this
export GLC_CAPTURE_GLFINISH=0

# take picture from front or back buffer
export GLC_CAPTURE=back

# compress stream using 'lzo', 'quicklz', 'lzjb' or 'none'
export GLC_COMPRESS=quicklz

# try GL_ARB_pixel_buffer_object to speed up readback
export GLC_TRY_PBO=1

# Skip audio packets. Not skipping requires some busy
# waiting and can slow program down a quite bit.
export GLC_AUDIO_SKIP=0

# show indicator when capturing
# NOTE this doesn't work properly when capturing front buffer
export GLC_INDICATOR=1

# start capturing immediately
export GLC_START=0

# capture hotkey, <Ctrl> and <Shift> mods are supported
export GLC_HOTKEY="<Ctrl>KP_Divide"

# lock fps when capturing
export GLC_LOCK_FPS=0

# saved stream colorspace, bgr or 420jpeg
# set 420jpeg to convert to Y'CbCr (420JPEG) at capture
# NOTE this is a lossy operation
export GLC_COLORSPACE=bgra

# crop capture area to WxH+X+Y
# export GLC_CROP=WxH+X+Y

# record alsa devices
# format is device#rate#channels;device2...
#export GLC_AUDIO_RECORD=hw:0,0#44100#2

# Use SCHED_RR rt priority for ALSA threads
export GLC_RTPRIO=1

# pipe raw video stream to an external tool
# 4 command line arguments are going to passed to the program:
#  1. video_size (wxh)
#  2. pixel_format (bgr24, bgra or rgb24)
#  3. fps
#  4. output filename
export GLC_PIPE="/home/aldn/bin/glcs_enc.sh"

#
# Flip vertically the images sent through the pipe
#
export GLC_PIPE_INVERT=1

# delay in ms between the creation of the pipe reader process
# and the time we start writting frames to the pipe.
# This can help keep audio/video in sync in a ffmpeg setup
# with several inputs and 1 of them is slow to initialize
# http://ffmpeg.org/pipermail/ffmpeg-devel/2014-March/155704.html
export GLC_PIPE_DELAY=0

# use GL_PACK_ALIGNMENT 8
#export GLC_CAPTURE_DWORD_ALIGNED=1

# set SDL audiodriver to alsa
#export SDL_AUDIODRIVER=alsa

# log verbosity
export GLC_LOG=4

#export GLC_FILE="%app%-%pid%-%capture%.glc"

# log file
export GLC_LOG_FILE="/tmp/glcs.log"

LD_PRELOAD=/usr/lib/libglc-hook.so "${@}"

