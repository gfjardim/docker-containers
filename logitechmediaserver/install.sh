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
add-apt-repository "deb http://us.archive.ubuntu.com/ubuntu/ trusty universe multiverse"
add-apt-repository "deb http://us.archive.ubuntu.com/ubuntu/ trusty-updates universe multiverse"

# Install Dependencies
apt-get update -qq
apt-get install -qy wget

#########################################
##             INSTALLATION            ##
#########################################

# Install LMS
OUT=$(wget -qO - http://downloads.slimdevices.com/nightly/index.php?ver=7.9)
# Try to catch the link or die
REGEX=".*href=\".(.*).deb\""
if [[ ${OUT} =~ ${REGEX} ]]; then
  URL="http://downloads.slimdevices.com/nightly${BASH_REMATCH[1]}.deb"
else
  exit 1
fi

wget -O /tmp/lms.deb $URL
dpkg -i /tmp/lms.deb
rm /tmp/lms.deb

#########################################
##                 CLEANUP             ##
#########################################

# Clean APT install files
apt-get clean -y
rm -rf /var/lib/apt/lists/* /var/cache/* /var/tmp/*
