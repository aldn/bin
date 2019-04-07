#!/bin/sh
(echo system_powerdown | socat - UNIX-CONNECT:monitor ) > /dev/null
