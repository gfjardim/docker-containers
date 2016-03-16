FROM phusion/baseimage:0.9.18
MAINTAINER gfjardim <gfjardim@gmail.com>

#########################################
##        ENVIRONMENTAL CONFIG         ##
#########################################
# Set correct environment variables
ENV HOME="/root" LC_ALL="C.UTF-8" LANG="en_US.UTF-8" LANGUAGE="en_US.UTF-8"
# Use baseimage-docker's init system
CMD ["supervisord", "-c", "/etc/supervisor.conf", "-n"]
# CMD ["/sbin/my_init"]

#########################################
##         RUN INSTALL SCRIPT          ##
#########################################
ADD * /tmp/
RUN /bin/bash /tmp/install.sh

#########################################
##         EXPORTS AND VOLUMES         ##
#########################################
VOLUME /config /downloads
EXPOSE 6789
