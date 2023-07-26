#!/bin/bash

#
# Define the packages required to build core
#
BUILD_DEPS="git clang build-essential libtool autotools-dev automake pkg-config bsdmainutils python3"

#
# Define the packages required to run core
#
RUNTIME_DEPS="libevent-dev libboost-dev libsqlite3-dev"

#
# Update Ubuntu
#
apt update && apt -y upgrade

#
# Install dependencies
#
apt -y install ${BUILD_DEPS} ${RUNTIME_DEPS}

#
# Clone bitcoin source
#
git clone https://github.com/bitcoin/bitcoin.git ${SOURCE_DIR}

#
# Configure bitcoin core build
#
git checkout ${CORE_VERSION} && \
    ./autogen.sh && \
    ./configure CXX=clang++ CC=clang \
    --without-gui \
    --disable-hardening \
    --disable-tests \
    --disable-gui-tests \
    --disable-bench \
    --disable-maintainer-mode \
    --disable-dependency-tracking

#
# Compile and install bitcoin core
#
make && make install

#
# Cleanup packages and build artifacts
#
apt -y purge ${BUILD_DEPS}
apt -y autoremove
apt clean
rm -rf ${SOURCE_DIR}
rm -rf /var/lib/apt/lists/*
