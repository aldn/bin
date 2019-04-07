#!/bin/sh


#for i in 20 23 25
#do
#	ffmpeg -y  -i mpeg/13.mkv -t 20 -ss 3:20 -vf bwdif=mode=1  -c:v libx264 -preset slow -crf $i -c:a copy 13_H264_$i.mkv
#done
#
#for i in 20 23 25
#do
#	ffmpeg -y  -i mpeg/13.mkv -t 20 -ss 3:20 -vf bwdif=mode=1 -c:v libx265 -preset slow -crf $i -c:a copy 13_HEVC_$i.mkv
#done


#ffmpeg -y  -i mpeg/13.mkv -t 20 -ss 3:20 -vf bwdif             -c:v libx264 -preset fast -crf 17 -an 13_bwdif.mkv
#ffmpeg -y  -i mpeg/13.mkv -t 20 -ss 3:20 -vf kerndeint         -c:v libx264 -preset fast -crf 17 -an 13_kerndeint.mkv
#ffmpeg -y  -i mpeg/13.mkv -t 20 -ss 3:20 -vf mcdeint=mode=slow -c:v libx264 -preset fast -crf 17 -an 13_mcdeint.mkv
#ffmpeg -y  -i mpeg/13.mkv -t 20 -ss 3:20 -vf nnedi=weights=nnedi3_weights.bin             -c:v libx264 -preset fast -crf 17 -an 13_nnedi.mkv
#ffmpeg -y  -i mpeg/13.mkv -t 20 -ss 3:20 -vf w3fdif            -c:v libx264 -preset fast -crf 17 -an 13_w3fdif.mkv
#ffmpeg -y  -i mpeg/13.mkv -t 20 -ss 3:20 -vf yadif             -c:v libx264 -preset fast -crf 17 -an 13_yadif.mkv

#ffmpeg -y  -i mpeg/13.mkv -t 20 -ss 3:20 -vf bwdif=mode=0   -c:v libx264 -preset fast -crf 17 -an 13_bwdif_0.mkv
#ffmpeg -y  -i mpeg/13.mkv -t 20 -ss 3:20 -vf bwdif=mode=1   -c:v libx264 -preset fast -crf 17 -an 13_bwdif_1.mkv

#ffmpeg -y  -i mpeg/13.mkv -t 20 -ss 3:20  -vn 13.wav

mkdir HEVC
for i in *
do
	echo '****************'
	echo '****************'
	echo $i
	echo '****************'
	echo '****************'
	
	ffmpeg -y  -i $i  -vf bwdif=mode=1 -c:v libx265 -preset slow -crf 20 -c:a copy HEVC/$i
done

