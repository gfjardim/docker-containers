#!/bin/bash

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

# Fix the timezone
if [[ $(cat /etc/timezone) != $TZ ]] ; then
  echo "$TZ" > /etc/timezone
  dpkg-reconfigure -f noninteractive tzdata
fi

#########################################
##    REPOSITORIES AND DEPENDENCIES    ##
#########################################

# Repositories
add-apt-repository "deb http://us.archive.ubuntu.com/ubuntu/ trusty universe multiverse"
add-apt-repository "deb http://us.archive.ubuntu.com/ubuntu/ trusty-updates universe multiverse"
add-apt-repository ppa:jon-severinsson/ffmpeg

# Use mirrors
sed -i -e "s#http://[^\s]*archive.ubuntu[^\s]* #mirror://mirrors.ubuntu.com/mirrors.txt #g" /etc/apt/sources.list

# Install Dependencies
apt-get update -qq
apt-get install -qy libxml2 \
                    sgml-base \
                    libsigc++-2.0-0c2a \
                    python2.7-minimal \
                    xml-core \
                    javascript-common \
                    libjs-jquery \
                    libjs-jquery-metadata \
                    libjs-jquery-tablesorter \
                    libjs-twitter-bootstrap \
                    libpython-stdlib \
                    python2.7 \
                    python-minimal \
                    python \
                    ffmpeg \
                    wget \
                    unrar \
                    unzip \
                    p7zip \
                    nzbget

# Clean APT install files
rm -rf /var/lib/apt/lists/*
apt-get autoremove -y
apt-get autoclean -y
