FROM phusion/baseimage:0.9.11
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

# CrashPlan version
ENV CP_VERSION 3.6.4

#########################################
##         RUN INSTALL SCRIPT          ##
#########################################

ADD install.sh /tmp/
RUN chmod +x /tmp/install.sh && /tmp/install.sh && rm /tmp/install.sh

#########################################
##       FILES AND CONFIGURATION       ##
#########################################

ADD crashplan-install.sh /opt/
RUN bash /opt/crashplan-install.sh && \
    mkdir -p /var/lib/crashplan && \
    chown -R nobody /usr/local/crashplan /var/lib/crashplan

#########################################
##         EXPORTS AND VOLUMES         ##
#########################################

VOLUME /data
EXPOSE 4243
EXPOSE 4242

#########################################
##          RUNTIME SERVICES           ##
#########################################

# Add config.sh to execute during container startup
RUN mkdir -p /etc/my_init.d
ADD config.sh /etc/my_init.d/config.sh

# Add crashplan to runit
RUN mkdir /etc/service/crashplan
ADD crashplan.sh /etc/service/crashplan/run

RUN chmod +x /etc/service/*/run /etc/my_init.d/*


