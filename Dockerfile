FROM ubuntu:latest as builder

#
# Declare bitcoin core version
#
ARG CORE_VERSION

#
# Set the source directory for bitcoin core
#
ARG SOURCE_DIR=/usr/local/src/bitcoin

#
# Copy the build script
#
COPY build.sh /tmp/

#
# Run the build script
#
RUN mkdir ${SOURCE_DIR}; (cd ${SOURCE_DIR} && bash /tmp/build.sh)