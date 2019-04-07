#!/bin/sh

# Takes JPEG files in current directory and creates Broadcast2000
# compatible list file with following entries:
# ---------------------- (start_of_list_file)
# JPEGLIST
# <framerate>
# <width_of_each_image> # MUST be equal
# <height_of_each_image>
# /<absolute_path>/file0001.jpg
# /<absolute_path>/file0002.jpg
# /<absolute_path>/file0003.jpg
# .............................
# /<absolute_path>/file<n>.jpg
# ---------------------- (end_of_list_file)

function usage()
{
	echo "
Synopsis: $0 [options] [name_of_list_file]

Options are:
        -f [framerate]   Number of frames to play in second
        -c               Converts all PNG files to JPEG before generating
                         the list. Useful when dealing with XaoS rendered
		         sequences of PNG images

In case list filename not defined, default name will be used.
There's no storage other than user's mind to read framerate from, so it should
be always given"
	exit
}

echo "Generator of JPEG lists used by Broadcast 2000"
echo "(c) 2002 Alexander Dunayevskyy"
echo "MIT License"
echo

# should we convert PNG files (from XaoS) to JPEG format?
CONVERT="0"

# parse argument list
while getopts "+cf:" opt $1 $2 $3; do
	case "$opt" in
		f)
			FRAMERATE=$OPTARG
			;;
		c)
			CONVERT="1"
			;;
		?)
			usage
			;;
		*)
			echo "Unknown option encountered: $opt"; usage
			;;
	esac
done

LISTFILE=${!OPTIND}

if [ -z $FRAMERATE ]; then
	echo "Error: framerate must be defined!"
	usage
fi

if [ -z $LISTFILE ]; then
	LISTFILE="movie.list"
fi


echo "NOTE: from now I assume that:"
echo "       frame rate                : $FRAMERATE"
echo "       list file                 : $LISTFILE"
echo "       need png->jpeg conversion : $CONVERT"


# this forces '*.ext' removal from 'for ...in..' loops
# if no matches were found
shopt -s nullglob

> $LISTFILE

# echo "# Hello you hardcore archanophiles! ;-)"
echo "JPEGLIST"			>> $LISTFILE
printf "%.3f\n" $FRAMERATE	>> $LISTFILE

printf "%s" "Looking for 'identify'......."
# invoke identify (ImageMagick package) for dimensions
if [ ! -x `which identify` ]; then
	echo
	echo "Cannot find 'identify'! Install ImageMagick properly."
	exit
fi
echo "found!"

# find ANY first image and determine its dimenstions
for i in *.jpg *.JPG *.png *.PNG; do
	echo $i
	## identify gives us string like this:
	# burnl000.jpg 320x239 DirectClass 47kb JPEG 0.0u 0:01
	## The second word is image "size" in form <width>x<height>
	## I use awk to get them both
	WIDTH=`identify $i | awk '{ split ($2,a,/[xX]/); print a[1] }'`
	HEIGHT=`identify $i | awk '{ split ($2,a,/[xX]/); print a[2] }'`
	
	break # get out of loop
done

echo "'identify' gave us:"
echo "     width  : $WIDTH"
echo "     height : $HEIGHT"
echo "$WIDTH"		>> $LISTFILE
echo "$HEIGHT"		>> $LISTFILE


# if we get list of PNGs, convert 'em all to JPEG first
if [ "$CONVERT" == "1" ]; then
	echo "Converting files to JPEG..."
	for i in *.png *.PNG; do
		echo "$i => ${i%.*}.jpg"
		convert -quality 100 $i ${i%.*}.jpg
	done
	echo
fi

echo "Writing JPEG list..."
# print actual list of frames
for i in *.jpg *.JPG; do
	echo "`pwd`/$i" >> $LISTFILE
done

echo "Done"

