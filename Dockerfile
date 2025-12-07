# Dockerfile

FROM ubuntu:18.04

# Install necessary packages
RUN apt-get update && \
    apt-get install -y software-properties-common && \
    add-apt-repository -y ppa:ubuntu-toolchain-r/test && \
    add-apt-repository -y ppa:git-core/ppa && \
    apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y sudo git gcc-9 g++-9 wget tar gzip rsync fuse ninja-build curl make texinfo libbfd-dev libunwind-dev

# Use alternative gcc
RUN update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-9 100 && \
    update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-9 100

# Add entrypoint
COPY scripts/docker-entrypoint.sh /usr/local/bin/
ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
CMD ["bash"]
