FROM phusion/baseimage:0.9.18
MAINTAINER gfjardim <gfjardim@gmail.com>

#########################################
##        ENVIRONMENTAL CONFIG         ##
#########################################
# Set correct environment variables
ENV CP_VERSION="4.6.0"
ENV USER_ID="0" GROUP_ID="0" TERM="xterm"

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
VOLUME /data /config
EXPOSE 4243 4242 4280