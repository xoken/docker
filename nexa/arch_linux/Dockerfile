# Use the official image as a parent image.
FROM archlinux:latest
# Create work directory
RUN mkdir -p /opt/work
# Install essentials
RUN pacman -Syy --noconfirm
RUN pacman -S --noconfirm stack
RUN pacman -S --noconfirm --needed base-devel
RUN pacman -S --noconfirm leveldb
RUN pacman -S --noconfirm libsecp256k1
RUN pacman -S --noconfirm jemalloc
# Stack upgrade
RUN stack upgrade
# Set the working directory.
WORKDIR /opt/work/
RUN git clone https://github.com/xoken/xoken-node.git
RUN git clone https://github.com/xoken/xoken-core.git
RUN git clone https://github.com/xoken/arivi-core.git
# Set the working directory.
WORKDIR /opt/work/xoken-node
# Trial build
RUN stack install  
