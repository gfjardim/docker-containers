#!/bin/bash
#########################################
##        ENVIRONMENTAL CONFIG         ##
#########################################

# Configure user nobody to match unRAID's settings
export DEBIAN_FRONTEND="noninteractive"
usermod -u 99 nobody
usermod -g 100 nobody
usermod -d /home nobody
chown -R nobody:users /home

# Disable SSH
rm -rf /etc/service/sshd /etc/service/cron /etc/service/syslog-ng /etc/my_init.d/00_regen_ssh_host_keys.sh

#########################################
##  FILES, SERVICES AND CONFIGURATION  ##
#########################################
mkdir -p /etc/service/nzbget
cp /tmp/nzbget-run.sh /etc/service/nzbget/run
cp /tmp/nzbget-finish.sh /etc/service/nzbget/finish

chmod -R 777 /etc/service /etc/my_init.d #/opt/nzbget-update-install.sh

#########################################
##    REPOSITORIES AND DEPENDENCIES    ##
#########################################

# Repositories
add-apt-repository "deb http://us.archive.ubuntu.com/ubuntu/ trusty universe multiverse"
add-apt-repository "deb http://us.archive.ubuntu.com/ubuntu/ trusty-updates universe multiverse"
apt-add-repository ppa:modriscoll/nzbget
add-apt-repository ppa:mc3man/trusty-media

# Use mirrors
sed -i -e "s#http://[^\s]*archive.ubuntu[^\s]* #mirror://mirrors.ubuntu.com/mirrors.txt #g" /etc/apt/sources.list

# Install Dependencies
apt-get update -qq
apt-get install -qy python \
                    ffmpeg \
                    wget \
                    unzip \
                    p7zip 

# Update unrar to the last version
wget http://www.rarlab.com/rar/rarlinux-x64-5.2.1b2.tar.gz -O - |tar zx --strip-components=1 -C /usr/bin/ rar/unrar

# Install nzbget
wget http://nzbget.net/download/nzbget-15.0-bin-linux.run -O /opt/install-nzbget.run
sh /opt/install-nzbget.run --destdir /opt/nzbget

#########################################
##                 CLEANUP             ##
#########################################

# Clean APT install files
apt-get clean -y
rm -rf /var/lib/apt/lists/* /var/cache/* /var/tmp/*
