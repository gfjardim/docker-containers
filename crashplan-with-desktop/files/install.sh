#!/bin/bash

#########################################
##        ENVIRONMENTAL CONFIG         ##
#########################################

# Configure user nobody to match unRAID's settings
export DEBIAN_FRONTEND="noninteractive"
usermod -u 99 nobody
usermod -g 100 nobody
usermod -m -d /nobody nobody
usermod -s /bin/bash nobody
usermod -a -G adm,sudo nobody
echo "nobody:PASSWD" | chpasswd

# Disable SSH
rm -rf /etc/service/sshd /etc/service/cron /etc/my_init.d/00_regen_ssh_host_keys.sh

#########################################
##    REPOSITORIES AND DEPENDENCIES    ##
#########################################

# Repositories
add-apt-repository "deb http://us.archive.ubuntu.com/ubuntu/ trusty universe multiverse"
add-apt-repository "deb http://us.archive.ubuntu.com/ubuntu/ trusty-updates universe multiverse"

# Add Oracle JAVA and accept it's license
add-apt-repository ppa:webupd8team/java
echo "oracle-java8-installer shared/accepted-oracle-license-v1-1 select true" | sudo /usr/bin/debconf-set-selections

# Install Dependencies
apt-get update -qq

# Install CrashPlan dependencies
apt-get install -qy --force-yes --no-install-recommends \
                grep \
                sed \
                cpio \
                gzip \
                wget \
                oracle-java8-installer \
                gtk2-engines-murrine \
                ttf-ubuntu-font-family 

# Install window manager and x-server
apt-get install -qy --force-yes --no-install-recommends \
                x11-xserver-utils \
                openbox \
                xfonts-base \
                xfonts-100dpi \
                xfonts-75dpi \
                libfuse2 \
                xbase-clients

# Install noVNC dependencies
apt-get install -qy --force-yes --no-install-recommends \
                python \
                git

#########################################
##  FILES, SERVICES AND CONFIGURATION  ##
#########################################

# CrashPlan Service
mkdir -p /etc/service/crashplan
cp /files/crashplan/service.sh /etc/service/crashplan/run

# CrashPlan Desktop
cp /files/crashplan/desktop.sh /opt/crashplan-desktop.sh
chmod +x /opt/crashplan-desktop.sh

# noVNC Service
mkdir -p /etc/service/novnc
cp /files/novnc/service.sh /etc/service/novnc/run

# Openbox Service
mkdir -p /etc/service/openbox
cp /files/openbox/service.sh /etc/service/openbox/run

# Openbox Autostart
mkdir -p /nobody/.config/openbox /nobody/.cache
cp /files/openbox/autostart.sh /nobody/.config/openbox/autostart
cp /files/openbox/rc.xml /nobody/.config/openbox/rc.xml

# TigerVNC Service
mkdir -p /etc/service/tigervnc
cp /files/tigervnc/service.sh /etc/service/tigervnc/run

# Config File
mkdir -p /etc/my_init.d
cp /files/config.sh /etc/my_init.d/config.sh

chmod -R +x /etc/service/ /etc/my_init.d/

#########################################
##             INSTALLATION            ##
#########################################

# Install Crashplan
/bin/bash /files/crashplan/install.sh

# Install TigerVNC
/bin/bash /files/tigervnc/install.sh

# Install noVNC
/bin/bash /files/novnc/install.sh

#########################################
##                 CLEANUP             ##
#########################################

# Clean APT install files
apt-get autoremove -y 
apt-get clean -y
rm -rf /var/lib/apt/lists/* /var/cache/* /var/tmp/*
