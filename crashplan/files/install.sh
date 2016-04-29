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
add-apt-repository "deb http://archive.ubuntu.com/ubuntu/ trusty universe multiverse"
add-apt-repository "deb http://archive.ubuntu.com/ubuntu/ trusty-updates universe multiverse"

# Add Oracle JAVA and accept it's license
add-apt-repository ppa:webupd8team/java
echo "oracle-java8-installer shared/accepted-oracle-license-v1-1 select true" | sudo /usr/bin/debconf-set-selections

# Local mirror
mkdir /opt/apt-select
URL=$(curl -sL https://github.com/jblakeman/apt-select/releases/latest | grep -Po "/jblakeman/apt-select/archive/.*.tar.gz")
curl -sL "https://github.com${URL}" | tar zx -C /opt/apt-select --strip-components=1
apt-get update -qq && apt-get -qy --force-yes install python3-bs4

cd /opt && python3 /opt/apt-select/apt-select.py -t 3 -m up-to-date
[ -f /opt/sources.list ] && mv /opt/sources.list /etc/apt/sources.list

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
mkdir -p /etc/service/crashplan /etc/service/crashplan/control
cp /files/crashplan/service.sh /etc/service/crashplan/run
cp /files/crashplan/service_stop.sh /etc/service/crashplan/control/t

# CrashPlan Desktop
cp /files/crashplan/desktop.sh /opt/startapp.sh
cp /files/crashplan/desktop_stop.sh /opt/stopapp.sh
chmod +x /opt/startapp.sh /opt/stopapp.sh

# noVNC Service
mkdir -p /etc/service/novnc
cp /files/novnc/service.sh /etc/service/novnc/run

# Openbox Service
mkdir -p /etc/service/openbox  /etc/service/openbox/control/
cp /files/openbox/service.sh /etc/service/openbox/run
cp /files/openbox/service_stop.sh /etc/service/openbox/control/t

# Openbox Autostart
mkdir -p /nobody/.config/openbox /nobody/.cache
cp /files/openbox/autostart.sh /nobody/.config/openbox/autostart
cp /files/openbox/rc.xml /nobody/.config/openbox/rc.xml

# TigerVNC Service
mkdir -p /etc/service/tigervnc
cp /files/tigervnc/service.sh /etc/service/tigervnc/run

# Config File
mkdir -p /etc/my_init.d
cp /files/00_config.sh /etc/my_init.d/00_config.sh
cp /files/01_config.sh /etc/my_init.d/01_config.sh

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
