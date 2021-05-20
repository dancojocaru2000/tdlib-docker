ARG DEBIAN_VERSION
FROM debian:${DEBIAN_VERSION} AS builder
WORKDIR /tdlib
ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get -y update && apt-get -y upgrade && apt-get -y install make git zlib1g-dev libssl-dev gperf php-cli cmake clang libc++-dev libc++abi-dev
RUN git clone https://github.com/tdlib/td.git .
ARG TDLIB_VER
RUN git checkout "tags/v${TDLIB_VER}"
RUN rm -rf build && mkdir build
WORKDIR /tdlib/build
RUN CXXFLAGS="-stdlib=libc++" CC=/usr/bin/clang CXX=/usr/bin/clang++ cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX:PATH=../tdlib ..
RUN cmake --build . --target prepare_cross_compiling
WORKDIR /tdlib
RUN php SplitSource.php
WORKDIR /tdlib/build
RUN cmake --build . --target install
WORKDIR /tdlib
RUN php SplitSource.php --undo

FROM debian:${DEBIAN_VERSION}
WORKDIR /tdlib
COPY --from=builder /tdlib/tdlib /tdlib
