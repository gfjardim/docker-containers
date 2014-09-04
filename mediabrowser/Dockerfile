FROM phusion/baseimage:0.9.11
MAINTAINER gfjardim <gfjardim@gmail.com>
ENV DEBIAN_FRONTEND noninteractive

# Set correct environment variables
ENV HOME /root
ENV LANGUAGE en_US.UTF-8
ENV LANG en_US.UTF-8
RUN locale-gen en_US en_US.UTF-8
RUN update-locale LANG=en_US.UTF-8
RUN dpkg-reconfigure locales

# Use baseimage-docker's init system
CMD ["/sbin/my_init"]

# Fix a Debianism of the nobody's uid being 65534
RUN usermod -u 99 nobody
RUN usermod -g 100 nobody

RUN apt-get update -qq

# Install MediaBrowser run dependencies
RUN apt-get install -qy --force-yes libmono-cil-dev Libgdiplus unzip wget

# Install MediaBrowser
RUN mkdir mkdir /opt/MediaBrowser && \
    cd /opt/MediaBrowser && \
    wget -nv -O MBServer.Mono.zip https://www.dropbox.com/s/07hh1g4x9xo28jb/MBServer.Mono.zip?dl=1 && \
    unzip MBServer.Mono.zip && \
    rm MBServer.Mono.zip

#VOLUMES
VOLUME /config
RUN rm -rf /opt/MediaBrowser/ProgramData-Server && \
    ln -sf /config/ /opt/MediaBrowser/ProgramData-Server && \
    chown -R nobody:users /opt/MediaBrowser

# Add media_browser.sh to runit
RUN mkdir /etc/service/media_browser
ADD media_browser.sh /etc/service/media_browser/run
RUN chmod +x /etc/service/media_browser/run
