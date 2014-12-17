FROM phusion/baseimage:0.9.15
MAINTAINER gfjardim <gfjardim@gmail.com>

#########################################
##        ENVIRONMENTAL CONFIG         ##
#########################################

# Set correct environment variables
ENV DEBIAN_FRONTEND noninteractive
ENV HOME            /root
ENV LC_ALL          C.UTF-8
ENV LANG            en_US.UTF-8
ENV LANGUAGE        en_US.UTF-8

# Use baseimage-docker's init system
CMD ["/sbin/my_init"]

#########################################
##         RUN INSTALL SCRIPT          ##
#########################################

ADD install.sh /tmp/
RUN chmod +x /tmp/install.sh && /tmp/install.sh && rm /tmp/install.sh

#########################################
##  FILES, SERVICES AND CONFIGURATION  ##
#########################################

# Files
ADD owncloud.site /etc/nginx/sites-enabled/owncloud
RUN rm -f /etc/nginx/sites-enabled/default

# Add custom PHP-FPM / Ningx configuration
ADD www.conf /etc/php5/fpm/pool.d/
ADD php.ini /etc/php5/fpm/
ADD nginx.conf /etc/nginx/

# Add services to runit
ADD config.sh /etc/my_init.d/config.sh
ADD nginx.sh /etc/service/nginx/run
ADD php-fpm.sh /etc/service/php-fpm/run

RUN chmod +x /etc/service/*/run /etc/my_init.d/*

#########################################
##         EXPORTS AND VOLUMES         ##
#########################################

VOLUME ["/var/www/owncloud/data"]
EXPOSE 8000

