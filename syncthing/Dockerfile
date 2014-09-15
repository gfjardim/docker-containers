FROM phusion/baseimage:0.9.11
MAINTAINER gfjardim <gfjardim@gmail.com>
ENV DEBIAN_FRONTEND noninteractive

# Set install version
ENV VERSION testing

# Set correct environment variables
ENV HOME /root

# Ensure UTF-8
RUN locale-gen en_US.UTF-8
ENV LANG       en_US.UTF-8
ENV LC_ALL     en_US.UTF-8

# Fix a Debianism of the nobody's uid being 65534
RUN usermod -u 99 nobody
RUN usermod -g 100 nobody

# Use baseimage-docker's init system
CMD ["/sbin/my_init"]

# Install Dependencies
RUN apt-get update -q
RUN apt-get install -qy --force-yes wget

# Install Syncthing
RUN mkdir -p /opt/syncthing && wget -nv -O - "https://github.com/syncthing/syncthing/releases/download/v0.9.15/syncthing-linux-amd64-v0.9.15.tar.gz" | tar -xzf - --strip-components=1 -C /opt/syncthing

# VOLUMES
VOLUME /config

# PORTS
EXPOSE 8080 22000 21025/udp

# Add syncthing to runit
RUN mkdir /etc/service/syncthing
ADD syncthing.sh /etc/service/syncthing/run
RUN chmod +x /etc/service/syncthing/run
