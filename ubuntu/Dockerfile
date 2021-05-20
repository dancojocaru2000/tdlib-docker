ARG UBUNTU_VERSION
FROM ubuntu:${UBUNTU_VERSION} AS builder
WORKDIR /tdlib
ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get -y update && apt-get -y upgrade && apt-get -y install make git zlib1g-dev libssl-dev gperf php-cli cmake clang-10 libc++-dev libc++abi-dev
RUN git clone https://github.com/tdlib/td.git .
ARG TDLIB_VER
RUN git checkout "tags/v${TDLIB_VER}"
RUN rm -rf build && mkdir build
WORKDIR /tdlib/build
RUN CXXFLAGS="-stdlib=libc++" CC=/usr/bin/clang-10 CXX=/usr/bin/clang++-10 cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX:PATH=../tdlib -DTD_ENABLE_LTO=ON -DCMAKE_AR=/usr/bin/llvm-ar-10 -DCMAKE_NM=/usr/bin/llvm-nm-10 -DCMAKE_OBJDUMP=/usr/bin/llvm-objdump-10 -DCMAKE_RANLIB=/usr/bin/llvm-ranlib-10 ..
RUN cmake --build . --target prepare_cross_compiling
WORKDIR /tdlib
RUN php SplitSource.php
WORKDIR /tdlib/build
RUN cmake --build . --target install
WORKDIR /tdlib
RUN php SplitSource.php --undo

FROM ubuntu:${UBUNTU_VERSION}
WORKDIR /tdlib
COPY --from=builder /tdlib/tdlib /tdlib
