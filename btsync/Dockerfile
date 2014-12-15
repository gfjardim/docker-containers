FROM phusion/baseimage:0.9.11
MAINTAINER gfjardim <gfjardim@gmail.com>

#########################################
##        ENVIRONMENTAL CONFIG         ##
#########################################

# Set correct environment variables
ENV DEBIAN_FRONTEND noninteractive
ENV HOME            /root
ENV LC_ALL          C.UTF-8
ENV LANG            en_US.UTF-8
ENV LANGUAGE        en_US.UTF-8

# Use baseimage-docker's init system
CMD ["/sbin/my_init"]

#########################################
##         RUN INSTALL SCRIPT          ##
#########################################

ADD install.sh /tmp/
RUN chmod +x /tmp/install.sh && /tmp/install.sh && rm /tmp/install.sh

#########################################
##       FILES AND CONFIGURATION       ##
#########################################

# Files
ADD btsync.conf /tmp/

#########################################
##         EXPORTS AND VOLUMES         ##
#########################################

VOLUME /config
EXPOSE 5555 8888

#########################################
##          RUNTIME SERVICES           ##
#########################################

# Add btsync to runit
RUN mkdir /etc/service/btsync
ADD btsync.sh /etc/service/btsync/run
RUN chmod +x /etc/service/btsync/run
