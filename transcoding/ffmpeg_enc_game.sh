O=
O+="-f avfoundation "
#O+="-framerate 60 "
O+="-framerate 60000/1001 "
O+="-pixel_format uyvy422 "
#O+="-video_size 1440x900 "
O+="-capture_cursor 1 "
O+="-i 1:0 "
O+="-vf scale=1440x900 "
O+="-vcodec libx264 -crf 0 -preset ultrafast "
O+="-acodec aac"

echo Command line : $O
ffmpeg -y $O out.mkv
