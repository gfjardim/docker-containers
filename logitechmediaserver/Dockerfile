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

ADD install_lms.sh /tmp/
RUN bash /tmp/install_lms.sh
RUN dpkg -i /tmp/lms.deb
RUN rm /tmp/install_lms.sh /tmp/lms.deb

#VOLUMES
VOLUME /config
VOLUME /music

#PORTS
EXPOSE 3483 9000 9090

# Add logitechmediaserver to runit
RUN mkdir /etc/service/logitechmediaserver
ADD logitechmediaserver.sh /etc/service/logitechmediaserver/run
RUN chmod +x /etc/service/logitechmediaserver/run
