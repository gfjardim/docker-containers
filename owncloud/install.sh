#!/bin/bash
OWNCLOUD_VERSION="8.0.2"

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
rm -rf /etc/service/sshd /etc/service/cron /etc/service/syslog-ng /etc/my_init.d/00_regen_ssh_host_keys.sh

#########################################
##    REPOSITORIES AND DEPENDENCIES    ##
#########################################

# Repositories
add-apt-repository "deb http://us.archive.ubuntu.com/ubuntu/ trusty universe multiverse"
add-apt-repository "deb http://us.archive.ubuntu.com/ubuntu/ trusty-updates universe multiverse"
add-apt-repository "deb http://archive.ubuntu.com/ubuntu/ trusty-proposed restricted main multiverse universe"
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
                    wget \
                    bzip2

apt-get install -qy -f php5-dev libpcre3-dev
pecl channel-update pecl.php.net
yes | pecl install -f channel://pecl.php.net/apcu-4.0.7
apt-get remove -qy -f php5-dev libpcre3-dev

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

# CONFIG
cat <<'EOT' > /etc/my_init.d/config.sh
#!/bin/bash

# # Upgrade ownCloud
# if [[ ! -f /tmp/.occ_updated ]]; then
#   /sbin/setuser nobody php /var/www/owncloud/occ upgrade
#   /usr/bin/php /opt/fix_config.php
#   touch /tmp/.occ_updated
# fi

# Fix the timezone
if [[ $(cat /etc/timezone) != $TZ ]] ; then
  echo "$TZ" > /etc/timezone
  dpkg-reconfigure -f noninteractive tzdata
  sed -i -e "s#;date.timezone.*#date.timezone = ${TZ}#g" /etc/php5/fpm/php.ini
fi

if [[ -z $DEFAULT_PORT ]]; then
  DEFAULT_PORT=8000
fi
sed -i -e "s#DEFAULT_PORT#${DEFAULT_PORT}#" /etc/nginx/sites-enabled/owncloud.site

if [[ -f /var/www/owncloud/data/server.key && -f /var/www/owncloud/data/server.pem ]]; then
  echo "Found pre-existing certificate, using it."
  cp -f /var/www/owncloud/data/server.* /opt/
else
  if [[ -z $SUBJECT ]]; then 
    SUBJECT="/C=US/ST=CA/L=Carlsbad/O=Lime Technology/OU=unRAID Server/CN=yourhome.com"
  fi
  echo "No pre-existing certificate found, generating a new one with subject:"
  echo $SUBJECT
  openssl req -new -x509 -days 3650 -nodes -out /opt/server.pem -keyout /opt/server.key \
          -subj "$SUBJECT"
  ls /opt/
  cp -f /opt/server.* /var/www/owncloud/data/
fi

if [[ ! -d /var/www/owncloud/data/config ]]; then
  mkdir /var/www/owncloud/data/config
fi

if [[ -d /var/www/owncloud/config ]]; then
  rm -rf /var/www/owncloud/config
  ln -sf /var/www/owncloud/data/config/ /var/www/owncloud/config
fi

# Copy ca-bundle file to config
if [[ ! -f /var/www/owncloud/config/ca-bundle.crt  ]]; then
  cp /opt/ca-bundle.crt /var/www/owncloud/config/ca-bundle.crt 
fi

chown -R nobody:users /var/www/owncloud
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
env[HOSTNAME] = $HOSTNAME
env[PATH] = /usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
env[TMP] = /tmp
env[TMPDIR] = /tmp
env[TEMP] = /tmp
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
  keepalive_timeout 1200;
  proxy_read_timeout  1800;
  fastcgi_read_timeout 1800;
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

#Create DH Parameters File
openssl dhparam -out /etc/ssl/certs/dhparam.pem 4096

# NGINX site
rm -f /etc/nginx/sites-enabled/default
cat <<'EOT' > /etc/nginx/sites-enabled/owncloud.site
upstream php-handler {
  server unix:/var/run/php5-fpm.sock;
}

server {
  listen DEFAULT_PORT ssl;
  server_name "";

  ssl_certificate /opt/server.pem;
  ssl_certificate_key /opt/server.key;
  
  ssl_dhparam /etc/ssl/certs/dhparam.pem;

  ssl_protocols TLSv1 TLSv1.1 TLSv1.2;
  ssl_ciphers "EECDH+AESGCM:EDH+AESGCM:ECDHE-RSA-AES128-GCM-SHA256:AES256+EECDH:DHE-RSA-AES128-GCM-SHA256:AES256+EDH:ECDHE-RSA-AES256-GCM-SHA384:DHE-RSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-SHA384:ECDHE-RSA-AES128-SHA256:ECDHE-RSA-AES256-SHA:ECDHE-RSA-AES128-SHA:DHE-RSA-AES256-SHA256:DHE-RSA-AES128-SHA256:DHE-RSA-AES256-SHA:DHE-RSA-AES128-SHA:ECDHE-RSA-DES-CBC3-SHA:EDH-RSA-DES-CBC3-SHA:AES256-GCM-SHA384:AES128-GCM-SHA256:AES256-SHA256:AES128-SHA256:AES256-SHA:AES128-SHA:DES-CBC3-SHA:HIGH:!aNULL:!eNULL:!EXPORT:!DES:!MD5:!PSK:!RC4";

  ssl_prefer_server_ciphers on;
  ssl_session_cache shared:SSL:10m;

  add_header Strict-Transport-Security "max-age=63072000; includeSubdomains; preload";

  # Force SSL
  error_page 497 https://$host:DEFAULT_PORT$request_uri;
  
  # Path to the root of your installation
  root /var/www/owncloud;
  
  client_max_body_size 0m;
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
    client_max_body_size 0m;
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

server {
  listen 8001;
  server_name "";
  
  # Path to the root of your installation
  root /var/www/owncloud;
  
  client_max_body_size 0m;
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
    client_max_body_size 0m;
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

cat <<'EOT' > /opt/fix_config.php
<?PHP
$config_file = "/var/www/owncloud/config/config.php";
require_once($config_file);

# Change values
$CONFIG['memcache.local'] = '\OC\Memcache\APCu';

# Save file
file_put_contents("${config_file}", '<?PHP'.PHP_EOL.'$CONFIG = '.var_export($CONFIG, TRUE).PHP_EOL.'?>' );
?>
EOT

chmod -R +x /etc/service/ /etc/my_init.d/

#########################################
##             INSTALLATION            ##
#########################################

# Install ownCloud
mkdir -p /var/www/
HTML=$(wget -qO - https://owncloud.org/changelog/)
REGEX="(https://download.owncloud.org/community/owncloud-[0-9.]*tar.bz2)"
if [[ $HTML =~ $REGEX ]]; then
  URL=${BASH_REMATCH[1]}
else
  exit 1
fi
curl -s -k -L "${URL}" | tar -jx -C /var/www
rm /var/www/owncloud/.user.ini
cp /var/www/owncloud/config/ca-bundle.crt /opt/ca-bundle.crt

#########################################
##                 CLEANUP             ##
#########################################

# Clean APT install files
apt-get clean -y
rm -rf /var/lib/apt/lists/* /var/cache/* /var/tmp/*
