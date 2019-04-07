#!/bin/bash
# atget - download trailers from Apple website

# Usage if no parameters given
if [ -z $@ ]; then
  echo " atget <apple-trailer-url>"; exit
fi


#http://trailers.apple.com/trailers/independent/touchback/
#->
#http://trailers.apple.com/movies/independent/touchback/touchback-tlr1_h1080p.mov

# Prepend 'h' before resolution to create a valid url
newurl=$(echo $@ | sed 's/_\([0-9]*[0-9][0-9][0-9]\)p.mov/_h\1p.mov/g')

echo "Fetching $newurl"

# Download trailer and save
#wget -U QuickTime/7.6.2 "$newurl" # -O ${@##*/}
