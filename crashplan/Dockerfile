FROM phusion/baseimage:0.9.19
MAINTAINER gfjardim <gfjardim@gmail.com>

#########################################
##        ENVIRONMENTAL CONFIG         ##
#########################################
# Set correct environment variables
ENV USER_ID="0" \
    GROUP_ID="0" \
    TERM="xterm" \
    CP_VERSION="4.8.0"

# Use baseimage-docker's init system
CMD ["/sbin/my_init"]

#########################################
##         RUN INSTALL SCRIPT          ##
#########################################
ADD ./files /files
RUN sync && /bin/bash /files/tmp/install.sh

#########################################
##         EXPORTS AND VOLUMES         ##
#########################################
VOLUME /data /config
EXPOSE 4243 4242 4280