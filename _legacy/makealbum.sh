#!/bin/sh

# This script renames all files in current directory
# consequently (i.e. '001.ext', '002.ext', ..., '999.ext'.
# You can specify a word to prefix the number with.
# I.e., 'rec075.mpg'. Also note that extension is left intouched.

declare -i counter=1

prefix=$1
digits=$2

if [ "$digits" = "" ]; then
	digits="4"
fi

if [ "$prefix" = "date" ]; then
	prefix=`date +%d-%m-%y`
fi

undo_script=".makealbum_undo.sh"

> $undo_script
echo "#!/bin/sh" >> $undo_script

# [from bashdoc]: prints extension of file prefixed with '.'
# Original version prints '.' ALWAYS, but this one prints
# nothing if there's no extension
function ext()
{
  local name=${1##*/}
  local name0="${name%.*}"
  local ext=${name0:+${name#$name0}}
  echo "$ext"
}


for i in *;
do
	# save extension
	ext=`ext $i`
	# this is the new name
	newname=`printf "${prefix}%.${digits}d${ext}" $counter`
	# rename src -> dest
	echo "$i -> $newname"
	mv "$i" "$newname"
	# write undo information
	echo mv "$newname" "$i" >> $undo_script
	counter=$counter+1
done
