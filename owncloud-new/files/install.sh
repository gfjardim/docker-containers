#!/bin/bash
DEVEL="yes"

#########################################
##        ENVIRONMENTAL CONFIG         ##
#########################################

# Configure user nobody to match unRAID's settings
export DEBIAN_FRONTEND="noninteractive"
usermod -u 99 nobody
usermod -g 100 nobody
usermod -d /home nobody
chown -R nobody:users /home

# Disable some services
rm -rf /etc/service/sshd /etc/service/syslog-ng /etc/my_init.d/00_regen_ssh_host_keys.sh

#########################################
##    REPOSITORIES AND DEPENDENCIES    ##
#########################################

# Repositories
add-apt-repository "deb http://archive.archive.ubuntu.com/ubuntu/ trusty universe multiverse"
add-apt-repository "deb http://archive.archive.ubuntu.com/ubuntu/ trusty-updates universe multiverse"
add-apt-repository "deb http://archive.ubuntu.com/ubuntu/ trusty-proposed restricted main multiverse universe"
[[ $DEVEL == yes ]] && curl -skL https://gist.githubusercontent.com/gfjardim/ab7b7f38b2b5cebf9982/raw/repo -o /etc/apt/sources.list

# Install Dependencies
apt-get update -qq
apt-get install -qy -f php5-cli \
                    php5-common \
                    php5-gd \
                    php5-pgsql \
                    php5-sqlite \
                    php5-mysqlnd \
                    php5-curl \
                    php5-intl \
                    php5-mcrypt \
                    php5-ldap \
                    php5-gmp \
                    php5-imagick \
                    php5-fpm \
                    php5-gd \
                    smbclient \
                    nginx \
                    openssl \
                    bzip2 \
                    mariadb-server

#########################################
##  FILES, SERVICES AND CONFIGURATION  ##
#########################################

# NGINX
mkdir -p /etc/service/nginx
cp /files/nginx/service.sh /etc/service/nginx/run
cp /files/nginx/nginx.conf /etc/nginx/nginx.conf

# PHP-FPM
mkdir -p /etc/service/php-fpm
cp /files/php-fpm/service.sh /etc/service/php-fpm/run
cp /files/php-fpm/www.conf /etc/php5/fpm/pool.d/www.conf

# ownCloud
mkdir -p /etc/service/owncloud
cp /files/owncloud/service.sh /etc/service/owncloud/run
rm -f /etc/nginx/sites-enabled/default
cp /files/owncloud/site /etc/nginx/sites-enabled/owncloud
cp /files/owncloud/fix_config.php /opt/fix_config.php
cp /files/owncloud/mysql_remote2local.sh /opt/mysql_remote2local.sh
chmod +x /opt/mysql_remote2local.sh

# MariaDB
mkdir -p /etc/service/mariadb
cp /files/mariadb/service.sh /etc/service/mariadb/run

# Config File
mkdir -p /etc/my_init.d
cp /files/config.sh /etc/my_init.d/config.sh
cp /files/00_config.sh /etc/my_init.d/00_config.sh

chmod -R +x /etc/service/ /etc/my_init.d/

#########################################
##             INSTALLATION            ##
#########################################

# APCu memcache install
/bin/bash /files/php-apcu/install.sh

# ownCloud install
/bin/bash /files/owncloud/install.sh

#########################################
##                 CLEANUP             ##
#########################################

# Clean APT install files
apt-get clean -y
rm -rf /var/lib/apt/lists/* /var/cache/* /var/tmp/*
