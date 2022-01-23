#! /usr/bin/env sh

# Parse arguments

help () {
	echo 'build.sh -- Ubuntu image'
	echo
	echo '    -v  --ubuntu $UBUNTU_VERSION:'
	echo '        specify version of Ubuntu Docker image'
	echo '    -t  --tag    $TDLIB_TAG:'
	echo '        specify the tdlib repository tag'
	echo '    -c  --commit $TDLIB_COMMIT:'
	echo '        specify the tdlib repository commit hash'
	exit 0
}

unknown_param () {
	echo 'build.sh: Unknown parameter $1'
	exit 1
}

while [ $# -gt 0 ]
do

	param="$1"
	shift
	case "$param" in
		"-v")
			;&
		"--ubuntu")
			export UBUNTU_VERSION=$1
			echo "UBUNTU_VERSION=$UBUNTU_VERSION"
			shift
			;;
		"-h")
			;&
		"--help")
			help
			;;
		"-t")
			;&
		"--tag")
			export TDLIB_TAG=$1
			echo "TDLIB_TAG=$TDLIB_TAG"
			shift
			;;
		"-c")
			;&
		"--commit")
			export TDLIB_COMMIT=$1
			echo "TDLIB_COMMIT=$TDLIB_COMMIT"
			shift
			;;
		*)
			unknown_param "$param"
			;;
	esac
done

if [ -z $UBUNTU_VERSION ]
then
    echo "build.sh: Please specify a version using -v"
    exit 1
fi

ram=$(free -m | grep -oP '\d+' | head -n 1) 
if [ $ram -lt 3584 ] # 3.5 GB RAM  = 3584 MB
then
	dockerfile=Dockerfile-low-ram
else
	dockerfile=Dockerfile
fi

if [ "$TDLIB_TAG" ]
then
	if [ -z "$IMAGE_TAG" ]
	then
		export IMAGE_TAG="tdlib:$TDLIB_TAG-$UBUNTU_VERSION"
	fi
	echo "IMAGE_TAG=$IMAGE_TAG"
	docker build \
		-t "$IMAGE_TAG" \
		--build-arg TDLIB_TAG \
		--build-arg UBUNTU_VERSION \
		-f $dockerfile \
		$(dirname $0)
elif [ "$TDLIB_COMMIT" ]
then
	if [ -z "$IMAGE_TAG" ]
	then
		export IMAGE_TAG="tdlib:$TDLIB_COMMIT-$UBUNTU_VERSION"
	fi
	echo "IMAGE_TAG=$IMAGE_TAG"
	docker build \
		-t "$IMAGE_TAG" \
		--build-arg TDLIB_COMMIT \
		--build-arg UBUNTU_VERSION \
		-f $dockerfile \
		$(dirname $0)
else
	echo 'build.sh: no commit or tag supplied'
	echo '    TIP: Find tags here: https://github.com/tdlib/td/tags'
	echo '    TIP: Find commits here: https://github.com/tdlib/td/commits/master'
	exit 1
fi

if [ -z $SO_IMAGE_TAG ]
then
	export SO_IMAGE_TAG="$IMAGE_TAG-so"
fi
echo "SO_IMAGE_TAG=$SO_IMAGE_TAG"
docker build \
	-t "$SO_IMAGE_TAG" \
	--build-arg "TDLIB_IMAGE=$IMAGE_TAG" \
	--build-arg UBUNTU_VERSION \
	-f Dockerfile-so \
	.
