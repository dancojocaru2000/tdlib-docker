#! /usr/bin/env sh

if [ -z $DEBIAN_VERSION ]
then
    echo "Please specify a version by setting the DEBIAN_VERSION env var"
    exit 1
fi

if [ $# -eq 1 ]
then
	export TDLIB_VER="$1"
else
	export TDLIB_VER="1.7.0"
fi

docker build -t "tdlib:$TDLIB_VER-$DEBIAN_VERSION" --build-arg TDLIB_VER --build-arg DEBIAN_VERSION .
