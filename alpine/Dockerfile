ARG ALPINE_VERSION
FROM alpine:${ALPINE_VERSION} AS builder
WORKDIR /tdlib
RUN apk update && apk upgrade && apk add --update alpine-sdk linux-headers git zlib-dev openssl-dev gperf php cmake
RUN git clone https://github.com/tdlib/td.git .
ARG TDLIB_VER
RUN git checkout "tags/v${TDLIB_VER}"
RUN rm -rf build && mkdir build
WORKDIR /tdlib/build
RUN cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX:PATH=../tdlib ..
RUN cmake --build . --target prepare_cross_compiling
WORKDIR /tdlib
RUN php SplitSource.php
WORKDIR /tdlib/build
RUN cmake --build . --target install
WORKDIR /tdlib
RUN php SplitSource.php --undo

FROM alpine:${ALPINE_VERSION}
WORKDIR /tdlib
COPY --from=builder /tdlib/tdlib /tdlib