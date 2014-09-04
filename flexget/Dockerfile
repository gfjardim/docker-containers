FROM phusion/baseimage:0.9.11
MAINTAINER none
ENV DEBIAN_FRONTEND noninteractive

# Set correct environment variables
ENV HOME /root

# Use baseimage-docker's init system
CMD ["/sbin/my_init"]

# Fix a Debianism of the nobody's uid being 65534
RUN usermod -u 99 nobody
RUN usermod -g 100 nobody
RUN usermod -d /config nobody

ADD sources.list /etc/apt/
RUN apt-get update -qq && \
    apt-get install -qq --force-yes python git python-transmissionrpc && \
    apt-get autoremove && \
    apt-get autoclean

RUN git clone https://github.com/Flexget/Flexget.git /opt/flexget
ADD https://pypi.python.org/packages/source/p/pip/pip-1.4.1.tar.gz /opt/flexget/pip-1.4.1.tar.gz
ADD https://pypi.python.org/packages/source/s/setuptools/setuptools-1.1.7.tar.gz /opt/flexget/setuptools-1.1.7.tar.gz

VOLUME /config
RUN ln -sf /config /root/.flexget

WORKDIR /opt/flexget
RUN python bootstrap.py
RUN bin/pip install -r jenkins-requirements.txt
RUN bin/pip install -r rtd-requirements.txt

# Add flexget to runit
#RUN mkdir /etc/service/flexget
#ADD flexget.sh /etc/service/flexget/run
#RUN chmod +x /etc/service/flexget/run

# Add flexget-webui to runit
RUN mkdir /etc/service/flexget-webui
ADD flexget-webui.sh /etc/service/flexget-webui/run
RUN chmod +x /etc/service/flexget-webui/run
