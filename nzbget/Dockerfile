FROM phusion/baseimage:0.9.11
MAINTAINER gfjardim <gfjardim@gmail.com>

#########################################
##        ENVIRONMENTAL CONFIG         ##
#########################################

# Set correct environment variables
ENV DEBIAN_FRONTEND noninteractive
ENV HOME /root

# Use baseimage-docker's init system
CMD ["/sbin/my_init"]

# Set the GIT_USER variable. It will be used to download files and updates.
ENV GIT_USER gfjardim

#########################################
##         RUN INSTALL SCRIPT          ##
#########################################

ADD install.sh /tmp/
RUN chmod +x /tmp/install.sh && /tmp/install.sh && rm /tmp/install.sh

#########################################
##       FILES AND CONFIGURATION       ##
#########################################

# Add nzbget in-app update scripts
ADD nzbget-update-install.sh /opt/
RUN chmod +x /opt/nzbget-update-install.sh
ADD package-info.json /opt/

#########################################
##         EXPORTS AND VOLUMES         ##
#########################################

VOLUME /config
VOLUME /downloads
EXPOSE 6789

#########################################
##          RUNTIME SERVICES           ##
#########################################

# Add config.sh to execute during container startup
RUN mkdir -p /etc/my_init.d
ADD config.sh /etc/my_init.d/config.sh

# Add nzbget to runit
RUN mkdir /etc/service/nzbget
ADD nzbget.sh /etc/service/nzbget/run

# Add update_service to runit
RUN mkdir /etc/service/update_service
ADD update_service.sh /etc/service/update_service/run

RUN chmod +x /etc/service/*/run /etc/my_init.d/*

