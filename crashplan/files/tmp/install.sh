#!/bin/bash

#########################################
##        ENVIRONMENTAL CONFIG         ##
#########################################

# Configure user nobody to match unRAID's settings
export DEBIAN_FRONTEND="noninteractive"
mkdir -p /nobody
usermod -u 99 nobody
usermod -g 100 nobody
usermod -m -d /nobody nobody
usermod -s /bin/bash nobody
usermod -a -G adm,sudo nobody

# Disable SSH
rm -rf /etc/service/sshd /etc/service/cron /etc/my_init.d/00_regen_ssh_host_keys.sh

cd /files && find . -type f -exec cp -f --parents '{}' / \;

#########################################
##    REPOSITORIES AND DEPENDENCIES    ##
#########################################

# Repositories
cat <<'EOT' > /etc/apt/sources.list
deb http://us.archive.ubuntu.com/ubuntu/ xenial main restricted universe multiverse 
deb http://us.archive.ubuntu.com/ubuntu/ xenial-security main restricted universe multiverse 
deb http://us.archive.ubuntu.com/ubuntu/ xenial-updates main restricted universe multiverse 
deb http://us.archive.ubuntu.com/ubuntu/ xenial-proposed main restricted universe multiverse 
deb http://us.archive.ubuntu.com/ubuntu/ xenial-backports main restricted universe multiverse 
EOT

# curl -skL https://repogen.simplylinux.ch/txt/xenial/sources_bbf3012a51a23b31db429017a1859e99ee11fc4c.txt -o /etc/apt/sources.list

# Install Dependencies
apt-get update -qq

# Install CrashPlan dependencies
apt-get install -qy --force-yes --no-install-recommends \
                grep \
                sed \
                cpio \
                gzip \
                wget \
                gtk2-engines \
                ttf-ubuntu-font-family \
                net-tools \
                paxctl

# Install window manager and x-server
apt-get install -qy --force-yes --no-install-recommends \
                x11-xserver-utils \
                openbox \
                xfonts-base \
                xfonts-100dpi \
                xfonts-75dpi \
                libfuse2 \
                xbase-clients \
                xkb-data

# Install noVNC dependencies
apt-get install -qy --force-yes --no-install-recommends \
                python \
                python-numpy \
                git

#########################################
##             INSTALLATION            ##
#########################################

sync

# Install Crashplan
/bin/bash /tmp/crashplan-install.sh

# Install TigerVNC
/bin/bash /tmp/tigervnc-install.sh

# Install noVNC
/bin/bash /tmp/novnc-install.sh

#########################################
##  FILES, SERVICES AND CONFIGURATION  ##
#########################################

chmod -R +x /etc/service/ /etc/my_init.d/ /opt/startapp.sh /opt/stopapp.sh
chown -R nobody:users /nobody
chmod 777 /tmp

#########################################
##                 CLEANUP             ##
#########################################

# Clean APT install files
apt-get autoremove -y 
apt-get clean -y
rm -rf /var/lib/apt/lists/* /var/cache/* /var/tmp/* /files/
