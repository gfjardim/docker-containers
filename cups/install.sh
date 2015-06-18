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
##    REPOSITORIES AND DEPENDENCIES    ##
#########################################

# Repositories
curl -skL https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add -
curl -skL http://www.bchemnet.com/suldr/suldr.gpg | apt-key add -
add-apt-repository "deb http://dl.google.com/linux/chrome/deb/ stable main"
add-apt-repository "deb http://www.bchemnet.com/suldr/ debian extra"

# Use mirrors
sed -i -e "s#http://[^\s]*archive.ubuntu[^\s]* #mirror://mirrors.ubuntu.com/mirrors.txt #g" /etc/apt/sources.list

# Install Dependencies
apt-get update -qq
apt-get install -qy --force-yes cups cups-pdf whois hplip suld-driver-4.01.17 google-chrome-stable python-cups inotify-tools

# Add AirPrint config tool
curl -skL https://raw.github.com/tjfontaine/airprint-generate/master/airprint-generate.py /opt/airprint-generate.py -o /opt/airprint-generate.py
chmod +x /opt/airprint-generate.py

#########################################
##  FILES, SERVICES AND CONFIGURATION  ##
#########################################

# Add files
cp -f /tmp/*.conf /etc/cups/
cp -f /tmp/etc-pam.d-cups /etc/pam.d/cups
cp -f /tmp/generate_cloudprint_config.py /opt/generate_cloudprint_config.py
chmod +x /opt/generate_cloudprint_config.py
mkdir -p /etc/cups/ssl

# Add services
# Add firstrun.sh to execute during container startup
mkdir -p /etc/my_init.d
cp /tmp/firstrun.sh /etc/my_init.d/firstrun.sh
chmod +x /etc/my_init.d/firstrun.sh

# Add cups to runit
mkdir /etc/service/cups
cp /tmp/start_cups.sh /etc/service/cups/run
chmod +x /etc/service/cups/run

# Add Chrome/CloudPrint to runit
mkdir /etc/service/chrome
cp /tmp/chrome.sh /etc/service/chrome/run
chmod +x /etc/service/chrome/run

# Add avahi-daemon to runit
mkdir /etc/service/avahi-daemon
cp /tmp/avahi-daemon.sh /etc/service/avahi-daemon/run
chmod +x /etc/service/avahi-daemon/run

# Add AirPrint to runit
mkdir /etc/service/air_print
cp /tmp/air_print.sh /etc/service/air_print/run
chmod +x /etc/service/air_print/run


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
