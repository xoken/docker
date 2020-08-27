# Use the official image as a parent image.
FROM ubuntu:20.04
# Create work directory
RUN mkdir -p /opt/work
# Install essentials
RUN apt update
RUN apt install -y haskell-stack
RUN apt install -y haskell-stack
RUN apt install -y libleveldb-dev
RUN apt install -y libssl-dev
RUN apt install -y git
RUN apt install -y build-essential
RUN apt install -y zlib1g-dev
RUN apt install -y libsecp256k1-dev
# Stack upgrade
RUN stack upgrade
RUN cp /root/.local/bin/stack /usr/bin/stack
# Set the working directory.
WORKDIR /opt/work/
RUN git clone https://github.com/xoken/xoken-node.git
RUN git clone https://github.com/xoken/xoken-core.git
RUN git clone https://github.com/xoken/arivi-core.git
RUN git clone https://github.com/xoken/xcql.git
# Set the working directory.
WORKDIR /opt/work/xoken-node
# Trial build
RUN stack install  


