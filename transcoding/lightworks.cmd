
SET app="C:\Program Files (x86)\VideoLAN\VLC\vlc" 
SET transcode_param=#transcode{venc=ffmpeg,vcodec=mp2v,vb=10240,vt=0,fps=24,acodec=mp2a,ab=490,channels=2,samplerate=48000,soverlay}
SET standard_param=standard{access=file,mux=ts,dst="%~n1.mpg"}

%app% -vvv %1 --sout=%transcode_param%:%standard_param% vlc://quit

