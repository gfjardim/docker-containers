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

# Disabling SSH
RUN rm -rf /etc/service/sshd /etc/my_init.d/00_regen_ssh_host_keys.sh

# Use baseimage-docker's init system
CMD ["/sbin/my_init"]

# Install Dependencies
RUN apt-get update -q
RUN apt-get install -qy --force-yes wget

# Install Syncthing
RUN mkdir -p /opt/btsync && wget -nv -O - "http://download.getsyncapp.com/endpoint/btsync/os/linux-x64/track/stable" |  tar -xzf - -C /opt/btsync

# VOLUMES
VOLUME /config

# PORTS
EXPOSE 5555 8888

# Files
ADD btsync.conf /tmp/

# Add btsync to runit
RUN mkdir /etc/service/btsync
ADD btsync.sh /etc/service/btsync/run
RUN chmod +x /etc/service/btsync/run
