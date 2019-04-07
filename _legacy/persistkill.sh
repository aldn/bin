#!/bin/sh

# ---** persistkill.sh **---
# Kill the program n times, if it persistently tries to respawn itself

[ "$1" != "" ] || ( echo "You must give a program name!" && exit )
echo "Trying to stop $1..."

declare -i i
for (( i=10; $i >0; i-- )); do
	echo "$i"
	killall -KILL $1
	sleep 1
done
