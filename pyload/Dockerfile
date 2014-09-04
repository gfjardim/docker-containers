FROM phusion/baseimage:0.9.11
MAINTAINER gfjardim <gfjardim@gmail.com>
ENV DEBIAN_FRONTEND noninteractive
ADD sources.list /etc/apt/

# Set correct environment variables
ENV HOME /root

# Ensure UTF-8
RUN locale-gen en_US.UTF-8
ENV LANG       en_US.UTF-8
ENV LC_ALL     en_US.UTF-8

# Fix a Debianism of the nobody's uid being 65534
RUN usermod -u 99 nobody
RUN usermod -g 100 nobody

# Use baseimage-docker's init system
CMD ["/sbin/my_init"]

# Install Dependencies
RUN apt-get update -q
RUN apt-get install -qy python-crypto python-pycurl tesseract-ocr git rhino unrar

# Checkout pyload sources
RUN git clone https://github.com/pyload/pyload.git /opt/pyload

# Add PyLoad Config Dir
ADD config/ /tmp/pyload-config/

# Exports and Volumes
VOLUME ["/downloads"]
VOLUME ["/config"]
EXPOSE 8000 7227 9666

# Add config.sh to execute during container startup
RUN mkdir -p /etc/my_init.d
ADD config.sh /etc/my_init.d/config.sh
RUN chmod +x /etc/my_init.d/config.sh

# Add pyload to runit
RUN mkdir /etc/service/pyload
ADD pyload.sh /etc/service/pyload/run
RUN chmod +x /etc/service/pyload/run

