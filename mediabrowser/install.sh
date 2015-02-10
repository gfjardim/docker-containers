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

#########################################
##    REPOSITORIES AND DEPENDENCIES    ##
#########################################

# Repositories
add-apt-repository "deb http://us.archive.ubuntu.com/ubuntu/ trusty main universe multiverse restricted"
add-apt-repository "deb http://us.archive.ubuntu.com/ubuntu/ trusty-updates main universe multiverse restricted"
add-apt-repository "deb http://ppa.launchpad.net/apps-z/mediabrowser/ubuntu trusty main"
add-apt-repository ppa:mc3man/trusty-media
apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 637D1286;

# Use mirrors
sed -i -e "s#http://[^\s]*archive.ubuntu[^\s]* #mirror://mirrors.ubuntu.com/mirrors.txt #g" /etc/apt/sources.list

# Install Dependencies
apt-get update -qq
apt-get install -qy --force-yes libmono-cil-dev \
                                Libgdiplus \
                                mediainfo \
                                libwebp-dev \
                                wget \
                                libsqlite3-dev \
                                ffmpeg \
                                mediabrowser

#########################################
##                 CLEANUP             ##
#########################################

# Clean APT install files
apt-get clean -y
rm -rf /var/lib/apt/lists/* /var/cache/* /var/tmp/*
