# tdlib-docker

[tdlib](https://github.com/tdlib/td) builds in a Docker container.

Also available on [DockerHub](https://hub.docker.com/repository/docker/kbruen/tdlib).

## Versions

The currently built versions are:

- `1.7.0-buster-slim`, `1.7.0-slim`, `buster-slim`, `slim`
- `1.7.0-alpine3.13`, `1.7.0-alpine3`, `1.7.0-alpine`, `alpine3.13`, `alpine3`, `alpine`

## How to use

The outputs of the build process are placed in the `/tdlib` folder in the image.

The best way to use the images is in a multi-stage build:

```dockerfile
FROM ghcr.io/dancojcoaru2000/tdlib:alpine3 AS tdlib

FROM alpine:3
COPY --from=tdlib /tdlib /tdlib/
```

## How to build

The files used to build the images are located in the [GitHub repository](https://github.com/dancojocaru2000/tdlib-docker).

To build an image, run one of the following commands:

- `env ALPINE_VERSION=3 alpine/build.sh 1.7.0`
- `env DEBIAN_VERSION=buster-slim debian/build.sh 1.7.0`
- `env UBUNTU_VERSION=focal ubuntu/build.sh 1.7.0`

The `*_VERSION` environment variable selects which Docker image version to base the build on.

The `1.7.0` parameter to the `build.sh` script specifies the [tdlib version tag](https://github.com/tdlib/td/tags).