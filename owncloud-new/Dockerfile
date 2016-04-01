FROM phusion/baseimage:0.9.18
MAINTAINER gfjardim <gfjardim@gmail.com>
ENV OWNCLOUD_VERSION="9.0.0"

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
VOLUME ["/config"]
EXPOSE 8000 8001
