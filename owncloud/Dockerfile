FROM phusion/baseimage:0.9.11
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

