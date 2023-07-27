FROM ubuntu:latest as builder

#
# Declare bitcoin core version
#
ARG CORE_VERSION

#
# Update Ubuntu
#
RUN apt update && apt -y upgrade

#
# Install build dependencies
#
RUN apt -y install git curl gnupg

#
# Set the working dir
#
WORKDIR /tmp

#
# Download bitcoin core and signatures
#
RUN curl https://bitcoincore.org/bin/bitcoin-core-${CORE_VERSION}/bitcoin-${CORE_VERSION}-$(uname -i)-linux-gnu.tar.gz -o bitcoin-${CORE_VERSION}-$(uname -i)-linux-gnu.tar.gz && \
    curl https://bitcoincore.org/bin/bitcoin-core-${CORE_VERSION}/SHA256SUMS -o SHA256SUMS && \
    curl https://bitcoincore.org/bin/bitcoin-core-${CORE_VERSION}/SHA256SUMS.asc -o SHA256SUMS.asc

#
# Verify checksums
#
RUN if [ -z $(sha256sum --ignore-missing --check SHA256SUMS | grep "OK") ]; then echo "Unable to verify checksums." && exit 2; fi

#
# Install GPG keys and verify signatures
#
RUN git clone https://github.com/bitcoin-core/guix.sigs && \
    gpg --import guix.sigs/builder-keys/* && \
    if [ -z $(gpg --verify SHA256SUMS.asc 2>&1 | grep "gpg: Good signature") ]; then echo "Unable to verify checksum signatures." && exit 3; fi

#
# Extract bitcoin core
#
RUN tar -zxvf bitcoin-${CORE_VERSION}-$(uname -i)-linux-gnu.tar.gz && mv bitcoin-${CORE_VERSION} bitcoin

#
# Cleanup files and paths
#
RUN rm bitcoin/README.md && \
    mkdir bitcoin/etc && \
    mv bitcoin/bitcoin.conf bitcoin/etc/bitcoin.conf

#
# Minimal bitcoin core
#
FROM ubuntu:latest

#
# Copy verified bitcoin core binaries and libraries
#
COPY --from=builder /tmp/bitcoin /usr/local

#
# Update and install tor
#
RUN apt -y update && \
    apt -y install tor && \
    apt clean && rm -rf /var/lib/apt/lists/*
