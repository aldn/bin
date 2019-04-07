#!/bin/sh

BASEURL=http://fotoapple.com
URL=$BASEURL/ru/browse/sex/page1-new/

L=$(curl -s $URL | grep -E  '\/ru\/photo\/[a-z0-9_]+\/' -o)

for IMG_URL in $L
do
    IMG_SRC=$(curl -s $BASEURL$IMG_URL | grep -E  '\/photos\/fullhd\/[a-z0-9_.]+jpg' -o |uniq)
    IMG_BASE_NAME=$(basename $IMG_SRC)
    if [ ! -f $IMG_BASE_NAME ]
    then
        echo getting $IMG_SRC
        curl -s $BASEURL$IMG_SRC -O
    else
        echo not getting $IMG_SRC because it exists
    fi
done
