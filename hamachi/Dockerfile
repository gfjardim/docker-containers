FROM phusion/baseimage:0.9.11
MAINTAINER gfjardim <gfjardim@gmail.com>
ENV DEBIAN_FRONTEND noninteractive
ADD sources.list /etc/apt/sources.list

# Set correct environment variables
ENV HOME /root

# Use baseimage-docker's init system
CMD ["/sbin/my_init"]

# Fix a Debianism of the nobody's uid being 65534
RUN usermod -u 99 nobody && \
    usermod -g 100 nobody

RUN apt-get update -q

# Install Hamachi
ADD https://secure.logmein.com/labs/logmein-hamachi-2.1.0.119-x64.tgz /tmp/hamachi.tgz
RUN mkdir -p /opt/logmein-hamachi
RUN tar -zxf /tmp/hamachi.tgz --strip-components 1 -C /opt/logmein-hamachi
RUN ln -sf /opt/logmein-hamachi/hamachid /usr/bin/hamachi
RUN rm /tmp/hamachi.tgz

VOLUME /config

# Add install.sh to execute during container startup
RUN mkdir -p /etc/my_init.d
ADD install.sh /etc/my_init.d/install.sh
RUN chmod +x /etc/my_init.d/install.sh

# Add hamachi.sh to runit
RUN mkdir /etc/service/hamachi
ADD hamachi.sh /etc/service/hamachi/run
RUN chmod +x /etc/service/hamachi/run
