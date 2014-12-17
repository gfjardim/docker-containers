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

# Set the GIT_USER variable. It will be used to download files and updates.
ENV GIT_USER gfjardim

#########################################
##  FILES, SERVICES AND CONFIGURATION  ##
#########################################

# Files
ADD nzbget-update-install.sh /opt/
RUN chmod +x /opt/nzbget-update-install.sh
ADD package-info.json /opt/

# Add services to runit
ADD config.sh /etc/my_init.d/config.sh
ADD nzbget.sh /etc/service/nzbget/run
ADD update_service.sh /etc/service/update_service/run

RUN chmod +x /etc/service/*/run /etc/my_init.d/*

#########################################
##         EXPORTS AND VOLUMES         ##
#########################################

VOLUME /config /downloads
EXPOSE 6789

#########################################
##         RUN INSTALL SCRIPT          ##
#########################################

ADD install.sh /tmp/
RUN chmod +x /tmp/install.sh && /tmp/install.sh && rm /tmp/install.sh

