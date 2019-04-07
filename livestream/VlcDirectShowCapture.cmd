
vlc -vvv dshow:// ^
:dshow-vdev="Dxtory Video 1" :dshow-adev=  :dshow-aspect-ratio=16\:10 ^
--sout=#transcode{vcodec=x264,vb=500,scale=1,acodec=mp4a,ab=128,channels=2,samplerate=48000}:^
standard{access=file,mux=mkv,dst=d:\LiveOutput\live1.mkv}
