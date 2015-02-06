#!/bin/bash

SERVIIO_LINK="http://download.serviio.org/releases/serviio-1.4.1.2-linux.tar.gz"

#########################################
##        ENVIRONMENTAL CONFIG         ##
#########################################

# Configure user nobody to match unRAID's settings
usermod -u 99 nobody
usermod -g 100 nobody
usermod -d /home nobody
chown -R nobody:users /home

# Disable SSH
rm -rf /etc/service/sshd /etc/my_init.d/00_regen_ssh_host_keys.sh

#########################################
##    REPOSITORIES AND DEPENDENCIES    ##
#########################################

# Repositories
add-apt-repository "deb http://us.archive.ubuntu.com/ubuntu/ trusty universe multiverse"
add-apt-repository "deb http://us.archive.ubuntu.com/ubuntu/ trusty-updates universe multiverse"
add-apt-repository ppa:webupd8team/java
add-apt-repository ppa:mc3man/trusty-media

# Accept JAVA license
echo "oracle-java7-installer shared/accepted-oracle-license-v1-1 select true" | /usr/bin/debconf-set-selections

sed -i -e "s#http://[^\s]*archive.ubuntu[^\s]* #mirror://mirrors.ubuntu.com/mirrors.txt #g" /etc/apt/sources.list

# Install Dependencies
apt-get update -qq
apt-get install -qy unzip gzip oracle-java8-installer wget ffmpeg

#########################################
##             INSTALLATION            ##
#########################################

# Install Serviio
mkdir -p /opt/serviio
wget -qO - "${SERVIIO_LINK}" | tar -zx -C /opt/serviio --strip-components 1

# Clean APT install files
apt-get clean -y
rm -rf /var/lib/apt/lists/* /var/tmp/* /var/cache/*
