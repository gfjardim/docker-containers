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

# Disable SSH, Cron and Syslog
rm -rf /etc/service/sshd /etc/service/cron /etc/service/syslog-ng /etc/my_init.d/00_regen_ssh_host_keys.sh

#########################################
##    REPOSITORIES AND DEPENDENCIES    ##
#########################################

cat <<'EOT' >/etc/apt/sources.list
#------------------------------------------------------------------------------#
#                            OFFICIAL UBUNTU REPOS                             #
#------------------------------------------------------------------------------#
deb http://us.archive.ubuntu.com/ubuntu/ xenial main restricted universe multiverse 
deb http://us.archive.ubuntu.com/ubuntu/ xenial-security main restricted universe multiverse 
deb http://us.archive.ubuntu.com/ubuntu/ xenial-updates main restricted universe multiverse 
deb http://us.archive.ubuntu.com/ubuntu/ xenial-proposed main restricted universe multiverse 
deb http://us.archive.ubuntu.com/ubuntu/ xenial-backports main restricted universe multiverse 
EOT

# Use mirrors
curl -skL https://repogen.simplylinux.ch/txt/xenial/sources_bbf3012a51a23b31db429017a1859e99ee11fc4c.txt -o /etc/apt/sources.list

# Repositories
curl -skL http://www.bchemnet.com/suldr/pool/debian/extra/su/suldr-keyring_2_all.deb -o /tmp/suldr-keyring.deb
dpkg -i /tmp/suldr-keyring.deb
add-apt-repository "deb http://www.bchemnet.com/suldr/ debian extra"

# Install Dependencies
apt-get update -qq
apt-get install --assume-yes --quiet \
        cups \
        cups-pdf \
        whois \
        hplip \
        suld-driver-4.01.17 \
        python-cups \
        python-pip \
        inotify-tools

# Install CloudPrint
pip install --upgrade pip
pip install cloudprint

# Add AirPrint config tool
curl -skL https://raw.github.com/tjfontaine/airprint-generate/master/airprint-generate.py -o /opt/airprint-generate.py
chmod +x /opt/airprint-generate.py

#########################################
##  FILES, SERVICES AND CONFIGURATION  ##
#########################################

# Copy files to their places
cd /files && find . -type f -exec cp -f --parents '{}' / \;
chmod -R +x /etc/service /etc/my_init.d

# Disbale some cups backend that are unusable within a container
mv /usr/lib/cups/backend/parallel /usr/lib/cups/backend-available/
mv /usr/lib/cups/backend/serial /usr/lib/cups/backend-available/

# Disable dbus for avahi
sed -i "s|#enable-dbus.*|enable-dbus=no|g" /etc/avahi/avahi-daemon.conf

#########################################
##                 CLEANUP             ##
#########################################

# Clean APT install files
apt-get clean -y
rm -rf /var/lib/apt/lists/* /var/cache/* /var/tmp/*
