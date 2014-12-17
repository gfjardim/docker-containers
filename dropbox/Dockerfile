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

# Add services to runit
ADD dropbox.sh /etc/service/dropbox/run

RUN chmod +x /etc/service/*/run /etc/my_init.d/*

#########################################
##         EXPORTS AND VOLUMES         ##
#########################################

EXPOSE 17500
VOLUME /home/.dropbox /home/Dropbox

#########################################
##         RUN INSTALL SCRIPT          ##
#########################################

ADD install.sh /tmp/
RUN chmod +x /tmp/install.sh && /tmp/install.sh && rm /tmp/install.sh