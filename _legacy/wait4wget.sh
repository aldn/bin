#!/bin/sh
for((;;))
do
	has_wget=$(ps axu | awk '{print $11}' | grep wget)
	if [ "$has_wget" = "" ]; then
		killall adialer
		killall pppd
		break
	fi
	sleep 1
done
