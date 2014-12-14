FROM phusion/baseimage:0.9.11
MAINTAINER gfjardim <gfjardim@gmail.com>

#########################################
##        ENVIRONMENTAL CONFIG         ##
#########################################

# Set correct environment variables
ENV DEBIAN_FRONTEND noninteractive
ENV HOME            /root
ENV RUNTIME_USER    nobody

# Ensure UTF-8
RUN locale-gen en_US.UTF-8
ENV LANG       en_US.UTF-8
ENV LC_ALL     en_US.UTF-8

# Configure user nobody to match unRAID's settings
RUN usermod -u 99 nobody && \
    usermod -g 100 nobody && \
    usermod -d /home nobody && \
    chown -R nobody:users /home

# Disable SSH
RUN rm -rf /etc/service/sshd /etc/my_init.d/00_regen_ssh_host_keys.sh

# Use baseimage-docker's init system
CMD ["/sbin/my_init"]


#########################################
##    REPOSITORIES AND DEPENDENCIES    ##
#########################################

# Use mirrors
#RUN sed -i -e "s#http://[^\s]*archive.ubuntu[^\s]* #http://sft.if.usp.br/ubuntu/ #g" /etc/apt/sources.list

# Install Dependencies
RUN apt-get update -q && \
    apt-get install -qy \
    php5-cli
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
    && rm -rf /var/lib/apt/lists/*


#########################################
##       FILES AND CONFIGURATION       ##
#########################################

# Install ownCloud
RUN mkdir /var/www
ADD http://download.owncloud.org/community/owncloud-latest.tar.bz2 /var/www/

# Add the site configuration
ADD owncloud.site /etc/nginx/sites-enabled/owncloud

# Remove default site
RUN rm -f /etc/nginx/sites-enabled/default

# Add custom PHP-FPM / Ningx configuration
ADD www.conf /etc/php5/fpm/pool.d/
ADD php.ini /etc/php5/fpm/
ADD nginx.conf /etc/nginx/


#########################################
##         EXPORTS AND VOLUMES         ##
#########################################

# Expose ownCloud's data dir
VOLUME ["/var/www/owncloud/data"]

# Expose port. Cannot be modified!
EXPOSE 8000


#########################################
##          RUNTIME SERVICES           ##
#########################################

# Add config.sh to execute during container startup
RUN mkdir -p /etc/my_init.d
ADD config.sh /etc/my_init.d/config.sh
RUN chmod +x /etc/my_init.d/config.sh

# Add Nginx to runit
RUN mkdir /etc/service/nginx
ADD nginx.sh /etc/service/nginx/run
RUN chmod +x /etc/service/nginx/run

# Add PHP-FPM to runit
RUN mkdir /etc/service/php-fpm
ADD php-fpm.sh /etc/service/php-fpm/run
RUN chmod +x /etc/service/php-fpm/run

