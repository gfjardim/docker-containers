FROM phusion/baseimage:0.9.15
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
##  FILES, SERVICES AND CONFIGURATION  ##
#########################################

# Files
ADD crashplan-install.sh /opt/

# Add config.sh to execute during container startup
ADD config.sh /etc/my_init.d/config.sh

# Add services to runit
ADD crashplan.sh /etc/service/crashplan/run

RUN chmod +x /etc/service/*/run /etc/my_init.d/*

#########################################
##         EXPORTS AND VOLUMES         ##
#########################################

VOLUME /data
EXPOSE 4243 4242

#########################################
##         RUN INSTALL SCRIPT          ##
#########################################

ADD install.sh /tmp/
RUN chmod +x /tmp/install.sh && /tmp/install.sh && rm /tmp/install.sh
