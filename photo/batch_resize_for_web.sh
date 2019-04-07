mkdir web
mogrify  -path web -resize 1000x1000 -unsharp 0x0.55+0.55+0.008 -quality 94 ./*.jpg

