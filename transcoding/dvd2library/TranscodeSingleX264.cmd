@echo off

echo **TRANSCODING TO H.264**

x264 --crf 22 --preset veryslow -o "h264\%~n1_video.mkv" %1

echo **MERGING VIDEO AND AUDIO**

mkvmerge -o "h264\%~n1.mkv" -D %1  "h264\%~n1_video.mkv"

del "h264\%~n1_video.mkv"

