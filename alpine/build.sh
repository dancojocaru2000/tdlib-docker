#! /usr/bin/env sh

if [ -z $ALPINE_VERSION ]
then
    echo "Please specify a version by setting the ALPINE_VERSION env var"
    exit 1
fi

if [ $# -eq 1 ]
then
	export TDLIB_VER="$1"
else
	export TDLIB_VER="1.7.0"
fi

docker build -t "tdlib:$TDLIB_VER-alpine-$ALPINE_VERSION" --build-arg TDLIB_VER --build-arg ALPINE_VERSION .