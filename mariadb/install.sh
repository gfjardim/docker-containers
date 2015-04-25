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
rm -rf /etc/service/sshd
rm /etc/my_init.d/00_regen_ssh_host_keys.sh

#########################################
##  FILES, SERVICES AND CONFIGURATION  ##
#########################################
# NGINX
mkdir -p /etc/service/nginx
cat <<'EOT' > /etc/service/nginx/run
#!/bin/bash
umask 000
exec /usr/sbin/nginx -g "daemon off;" -c /etc/nginx/nginx.conf
EOT

#MariaDB
mkdir -p /etc/service/mariadb
cat <<'EOT' > /etc/service/mariadb/run
#!/bin/bash
start_mysql(){
  /usr/bin/mysqld_safe --datadir=/db > /dev/null 2>&1 &
  RET=1
  while [[ RET -ne 0 ]]; do
    mysql -uroot -e "status" > /dev/null 2>&1
    RET=$?
    sleep 1
  done
}

if [[ ! -f /tmp/.mysql_configured ]]; then
  start_mysql
  # If databases do not exist create them
  if [ -f /db/mysql/user.MYD ]; then
    echo "Database exists."
  else
    echo "Creating database."
    /usr/bin/mysql_install_db --datadir=/db >/dev/null 2>&1
  fi
  mysql -uroot -e "GRANT ALL PRIVILEGES ON *.* TO 'root'@'localhost' WITH GRANT OPTION;"
  mysqladmin -u root shutdown
  touch /tmp/.mysql_configured
fi

echo "Starting MariaDB..."
/usr/bin/mysqld_safe --skip-syslog --datadir='/db'
EOT

# PHP-FPM
mkdir -p /etc/service/php-fpm
cat <<'EOT' > /etc/service/php-fpm/run
#!/bin/bash
umask 000
exec /usr/sbin/php5-fpm --nodaemonize --fpm-config /etc/php5/fpm/php-fpm.conf
EOT

chmod -R +x /etc/service/ /etc/my_init.d/

#########################################
##    REPOSITORIES AND DEPENDENCIES    ##
#########################################

# Repositories
add-apt-repository "deb http://us.archive.ubuntu.com/ubuntu/ trusty universe multiverse"
add-apt-repository "deb http://us.archive.ubuntu.com/ubuntu/ trusty-updates universe multiverse"
add-apt-repository "deb http://archive.ubuntu.com/ubuntu/ trusty-proposed restricted main multiverse universe"

# Install Dependencies
apt-get update -qq
apt-get install -qy mariadb-server \
                    php5-cli \
                    php5-mysqlnd \
                    php5-fpm \
                    nginx \
                    wget

#########################################
##             INSTALLATION            ##
#########################################

# Tweak my.cnf
sed -i -e 's#\(bind-address.*=\).*#\1 0.0.0.0#g' /etc/mysql/my.cnf
sed -i -e 's#\(log_error.*=\).*#\1 /db/mysql_safe.log#g' /etc/mysql/my.cnf
sed -i -e 's/\(user.*=\).*/\1 nobody/g' /etc/mysql/my.cnf

# InnoDB engine to use 1 file per table, vs everything in ibdata.
echo '[mysqld]' > /etc/mysql/conf.d/innodb_file_per_table.cnf
echo 'innodb_file_per_table' >> /etc/mysql/conf.d/innodb_file_per_table.cnf

# Add NGINX service
cat <<'EOT' > /etc/nginx/sites-enabled/default 
upstream php-handler {
  server unix:/var/run/php5-fpm.sock;
}
server {
  listen 3380;
  server_name "";
  root /var/www/phpMyAdmin/;
  index index.php index.html index.htm;
  location ~ \.php(?:$|/) {
    fastcgi_split_path_info ^(.+\.php)(/.+)$;
    include fastcgi_params;
    fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
    fastcgi_param PATH_INFO $fastcgi_path_info;
    fastcgi_pass php-handler;
  }
}
EOT

# Install phpMyAdmin
mkdir -p /var/www/phpMyAdmin
wget -qO - "http://sourceforge.net/projects/phpmyadmin/files/phpMyAdmin/4.3.12/phpMyAdmin-4.3.12-all-languages.tar.gz/download" | tar -zx -C /var/www/phpMyAdmin --strip=1

# Add phpMyAdmin config
cat <<'EOT' > /var/www/phpMyAdmin/config.inc.php
<?php
/* Server: docker mysql [1] */
$cfg['Servers'][1]['verbose'] = 'docker mysql';
$cfg['Servers'][1]['host'] = '127.0.0.1';
$cfg['Servers'][1]['port'] = '3306';
$cfg['Servers'][1]['socket'] = '';
$cfg['Servers'][1]['connect_type'] = 'tcp';
$cfg['Servers'][1]['auth_type'] = 'cookie';
$cfg['Servers'][1]['user'] = 'root';
$cfg['Servers'][1]['password'] = '';
$cfg['Servers'][1]['AllowNoPassword'] = true;
/* End of servers configuration */
$cfg['DefaultLang'] = 'en';
$cfg['ServerDefault'] = 1;
$cfg['UploadDir'] = '';
$cfg['SaveDir'] = '';
?>
EOT


#########################################
##                 CLEANUP             ##
#########################################

# Clean APT install files
apt-get clean -y
rm -rf /var/lib/apt/lists/* /var/cache/* /var/tmp/*
