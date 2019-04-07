#!/bin/sh
# Kill Internet Session
xkbbell
usleep 100000
killall pppd
killall -9 kppp
xkbbell
