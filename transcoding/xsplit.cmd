
set input=%1
set video2="%~d1%~p1%~n1_video.mp4"
set output="%~d1%~p1%~n1-.mp4"

rem --frames 1000
x264  --preset=slow --crf 40 -o %video2%  %input%

mp4box -add %input%#audio -add %video2%#video %output%

del %video2%

pause