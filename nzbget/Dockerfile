FROM phusion/baseimage:0.9.11
MAINTAINER needo <needo@superhero.org>
ENV DEBIAN_FRONTEND noninteractive

# Set correct environment variables
ENV HOME /root

# Set the GIT_USER variable. It will be used to download files and updates.
ENV GIT_USER gfjardim

# Use baseimage-docker's init system
CMD ["/sbin/my_init"]

# Fix a Debianism of the nobody's uid being 65534
RUN usermod -u 99 nobody
RUN usermod -g 100 nobody

ADD sources.list /etc/apt/
RUN add-apt-repository ppa:jon-severinsson/ffmpeg
RUN apt-get update -qq

# install nzbget dependencies
RUN apt-get install -y libxml2 sgml-base libsigc++-2.0-0c2a python2.7-minimal xml-core javascript-common \
    libjs-jquery libjs-jquery-metadata libjs-jquery-tablesorter libjs-twitter-bootstrap libpython-stdlib \
    python2.7 python-minimal python ffmpeg wget unrar unzip p7zip nzbget

# Add the build script
ADD build.sh /opt/
RUN chmod +x /opt/build.sh

# Add the package info file
ADD package-info.json /opt/

# Add nzbget in-app update scripts
ADD nzbget-update-install.sh /opt/
RUN chmod +x /opt/nzbget-update-install.sh
ADD package-info.json /opt/

#Path to a directory that only contains the nzbget.conf
VOLUME /config
VOLUME /downloads

EXPOSE 6789

# Add firstrun.sh to execute during container startup
RUN mkdir -p /etc/my_init.d
ADD firstrun.sh /etc/my_init.d/firstrun.sh
RUN chmod +x /etc/my_init.d/firstrun.sh

# Add nzbget to runit
RUN mkdir /etc/service/nzbget
ADD nzbget.sh /etc/service/nzbget/run
RUN chmod +x /etc/service/nzbget/run

# Add update_service to runit
RUN mkdir /etc/service/update_service
ADD update_service.sh /etc/service/update_service/run
RUN chmod +x /etc/service/update_service/run
