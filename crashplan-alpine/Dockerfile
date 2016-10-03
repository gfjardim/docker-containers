FROM anapsix/alpine-java:8_server-jre
MAINTAINER gfjardim <gfjardim@gmail.com>

ENV PS1="$(whoami)@$(hostname):$(pwd)$" HOME="/root" TERM="xterm" LANG="C.UTF-8"

ENTRYPOINT ["/init"]

#########################################
##         RUN INSTALL SCRIPT          ##
#########################################
ADD ./files /files/
RUN /bin/bash /files/install.sh

#########################################
##         EXPORTS AND VOLUMES         ##
#########################################
VOLUME /data /config
EXPOSE 5901
