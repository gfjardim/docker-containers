#!/bin/bash
EXTPLORER_VERSION="2.1.7"

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
export DEBIAN_FRONTEND="noninteractive"
apt-get update -qq
apt-get install -qy mariadb-server \
                    php5-cli \
                    php5-mysqlnd \
                    php5-fpm \
                    nginx \
                    wget \
                    unzip

#########################################
##  FILES, SERVICES AND CONFIGURATION  ##
#########################################
# NGINX
mkdir -p /etc/service/nginx
cat <<'EOT' > /etc/service/nginx/run
#!/bin/bash
umask 000
exec /usr/sbin/nginx -c /etc/nginx/nginx.conf
EOT

# PHP-FPM
mkdir -p /etc/service/php-fpm
cat <<'EOT' > /etc/service/php-fpm/run
#!/bin/bash
umask 000
exec /usr/sbin/php5-fpm --nodaemonize --fpm-config /etc/php5/fpm/php-fpm.conf
EOT

#PHP-FPM config
cat <<'EOT' > /etc/php5/fpm/pool.d/www.conf
[global]
daemonize = no

[www]
user = nobody
group = users
listen = /var/run/php5-fpm.sock
listen.mode = 0666
pm = dynamic
pm.max_children = 50
pm.start_servers = 3
pm.min_spare_servers = 2
pm.max_spare_servers = 4
pm.max_requests = 500
php_admin_value[upload_max_filesize] = 100G
php_admin_value[post_max_size] = 100G
php_admin_value[default_charset] = UTF-8
php_admin_value[max_execution_time] = 0
EOT

# NGINX config
cat <<'EOT' > /etc/nginx/nginx.conf
user nobody users;
daemon off;
worker_processes 4;
pid /run/nginx.pid;

events {
  worker_connections 768;
}

http {
  sendfile on;
  tcp_nopush on;
  tcp_nodelay on;
  keepalive_timeout 65;
  types_hash_max_size 2048;
  include /etc/nginx/mime.types;
  default_type application/octet-stream;
  access_log /var/log/nginx/access.log;
  error_log /var/log/nginx/error.log;
  gzip on;
  gzip_disable "msie6";
  ssl_protocols TLSv1 TLSv1.1 TLSv1.2;
  include /etc/nginx/conf.d/*.conf;
  include /etc/nginx/sites-enabled/*;
}
EOT

# NGINX site
rm -f /etc/nginx/sites-enabled/default
cat <<'EOT' > /etc/nginx/sites-enabled/eXtplorer.site
upstream php-handler {
  server unix:/var/run/php5-fpm.sock;
}

server {
  listen 8088;
  server_name "";
  
  # Path to the root of your installation
  root /var/www/eXtplorer;
  
  client_max_body_size 100G;
  fastcgi_buffers 64 4K;
  
  rewrite ^/caldav(.*)$ /remote.php/caldav$1 redirect;
  rewrite ^/carddav(.*)$ /remote.php/carddav$1 redirect;
  rewrite ^/webdav(.*)$ /remote.php/webdav$1 redirect;
  
  index index.php;
  error_page 403 /core/templates/403.php;
  error_page 404 /core/templates/404.php;
  
  location = /robots.txt {
    allow all;
    log_not_found off;
    access_log off;
  }

  location ~ ^/(?:\.htaccess|data|config|db_structure\.xml|README) {
    deny all;
  }

  location / {
    # The following 2 rules are only needed with webfinger
    rewrite ^/.well-known/host-meta /public.php?service=host-meta last;
    rewrite ^/.well-known/host-meta.json /public.php?service=host-meta-json last;
    rewrite ^/.well-known/carddav /remote.php/carddav/ redirect;
    rewrite ^/.well-known/caldav /remote.php/caldav/ redirect;
    rewrite ^(/core/doc/[^\/]+/)$ $1/index.html;
    try_files $uri $uri/ index.php;
  }
  
  location ~ \.php(?:$|/) {
    fastcgi_split_path_info ^(.+\.php)(/.+)$;
    include fastcgi_params;
    fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
    fastcgi_param PATH_INFO $fastcgi_path_info;
    fastcgi_pass php-handler;
  }
  
  # Optional: set long EXPIRES header on static assets
  location ~* \.(?:jpg|jpeg|gif|bmp|ico|png|css|js|swf)$ {
    expires 30d;
    # Optional: Don't log access to assets
    access_log off;
  }
}
EOT

chmod -R +x /etc/service/ /etc/my_init.d/

#########################################
##             INSTALLATION            ##
#########################################

# Install eXtplorer
mkdir -p /var/www/eXtplorer/
wget -qO /var/www/extplorer.zip "http://extplorer.net/attachments/download/57/eXtplorer_${EXTPLORER_VERSION}.zip"
unzip /var/www/extplorer.zip -d  /var/www/eXtplorer/
chown -R nobody:users /var/www/eXtplorer
rm /var/www/extplorer.zip

#########################################
##                 CLEANUP             ##
#########################################

# Clean APT install files
apt-get clean -y
rm -rf /var/lib/apt/lists/* /var/cache/* /var/tmp/*
