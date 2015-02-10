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
apt-get install -qy php5-cli \
                    php5-gd \
                    php5-pgsql \
                    php5-sqlite \
                    php5-mysqlnd \
                    php5-curl \
                    php5-intl \
                    php5-mcrypt \
                    php5-ldap \
                    php5-gmp \
                    php5-apcu \
                    php5-imagick \
                    php5-fpm \
                    smbclient \
                    nginx \
                    openssl \
                    wget

mkdir -p /var/www/

url="https://owncloud.org/install/"
regex="<a href=\"([^\"]*)\">Unix</a>"
if [[ $(wget -qO - ${url}) =~ $regex ]]; then
  download=${BASH_REMATCH[1]}
else
  exit 1
fi

wget -qO - $download | tar -jx -C /var/www

#########################################
##                 CLEANUP             ##
#########################################

# Clean APT install files
apt-get clean -y
rm -rf /var/lib/apt/lists/* /var/cache/* /var/tmp/*
