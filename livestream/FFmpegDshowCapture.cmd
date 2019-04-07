set filename=Diablo III %date:~-4,4%-%date:~-7,2%-%date:~-10,2% %time:~-11,2%-%time:~-8,2%-%time:~-5,2%
c:\ffmpeg\ffmpeg.exe ^
 -threads 8 ^
 -rtbufsize 200000k ^
 -f dshow -i video="Dxtory Video 1"      ^
 -f dshow -i audio="virtual-audio-capturer" ^
 -f dshow -channels 1 -i audio="IN (UA-25EX)"  ^
 -vcodec huffyuv -pix_fmt yuv420p ^
 -b:a 160k ^
 -filter_complex amix=inputs=2 ^
 -aspect 16:10 -vf scale=1280:720 -qscale 2 -y "d:\LiveOutput\%filename%.mkv"
