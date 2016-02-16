FROM phusion/baseimage:0.9.18
MAINTAINER gfjardim <gfjardim@gmail.com>
ENV OWNCLOUD_VERSION="8.2.2"

#########################################
##        ENVIRONMENTAL CONFIG         ##
#########################################
# Set correct environment variables
ENV HOME="/root" LC_ALL="C.UTF-8" LANG="en_US.UTF-8" LANGUAGE="en_US.UTF-8" TERM=xterm

# Use baseimage-docker's init system
CMD ["/sbin/my_init"]

#########################################
##         RUN INSTALL SCRIPT          ##
#########################################
ADD ./files /files/
RUN /bin/bash /files/install.sh

#########################################
##         EXPORTS AND VOLUMES         ##
#########################################
VOLUME ["/var/www/owncloud/data"]
EXPOSE 8000 8001
