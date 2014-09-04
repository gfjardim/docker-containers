FROM phusion/baseimage:0.9.11
MAINTAINER gfjardim <gfjardim@gmail.com>
ENV DEBIAN_FRONTEND noninteractive

# Set correct environment variables
ENV HOME /root

# Use baseimage-docker's init system
CMD ["/sbin/my_init"]

RUN add-apt-repository "deb http://us.archive.ubuntu.com/ubuntu/ trusty universe multiverse"
RUN add-apt-repository "deb http://us.archive.ubuntu.com/ubuntu/ trusty-updates universe multiverse"

# Add the JAVA repository, import it's key and accept it's license
RUN echo "deb http://ppa.launchpad.net/webupd8team/java/ubuntu trusty main" >> /etc/apt/sources.list
RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys EEA14886
RUN echo "oracle-java7-installer shared/accepted-oracle-license-v1-1 select true" | sudo /usr/bin/debconf-set-selections

RUN apt-get update -qq && \
    apt-get install -qq --force-yes grep sed cpio gzip oracle-java7-installer && \
    apt-get autoremove && \
    apt-get autoclean

RUN usermod -u 99 nobody && \
    usermod -g 100 nobody

ADD crashplan-install.sh /opt/
RUN bash /opt/crashplan-install.sh && \
    mkdir -p /var/lib/crashplan && \
    chown -R nobody /usr/local/crashplan /var/lib/crashplan

VOLUME /data

EXPOSE 4243
EXPOSE 4242

# Add config.sh to execute during container startup
RUN mkdir -p /etc/my_init.d
ADD config.sh /etc/my_init.d/config.sh
RUN chmod +x /etc/my_init.d/config.sh

# Add Sickbeard to runit
RUN mkdir /etc/service/crashplan
ADD CrashPlan.sh /etc/service/crashplan/run
RUN chmod +x /etc/service/crashplan/run

