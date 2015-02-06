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
apt-add-repository ppa:modriscoll/nzbget
add-apt-repository ppa:mc3man/trusty-media

# Use mirrors
#sed -i -e "s#http://[^\s]*archive.ubuntu[^\s]* #mirror://mirrors.ubuntu.com/mirrors.txt #g" /etc/apt/sources.list

# Install Dependencies
apt-get update -qq
apt-get install -qy libxml2 \
                    sgml-base \
                    libsigc++-2.0-0c2a \
                    xml-core \
                    javascript-common \
                    libjs-jquery \
                    libjs-jquery-metadata \
                    libjs-jquery-tablesorter \
                    libjs-twitter-bootstrap \
                    libpython-stdlib \
                    python \
                    ffmpeg \
                    wget \
                    unrar \
                    unzip \
                    p7zip \
                    nzbget

# Update unrar to the last version
wget http://www.rarlab.com/rar/rarlinux-x64-5.2.1b2.tar.gz -O - |tar zx --strip-components=1 -C /usr/bin/ rar/unrar

#########################################
##                 CLEANUP             ##
#########################################

# Clean APT install files
apt-get clean -y
rm -rf /var/lib/apt/lists/* /var/cache/* /var/tmp/*
