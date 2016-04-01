#!/bin/bash

# Fix the timezone
if [[ $(cat /etc/timezone) != $TZ ]] ; then
  echo "$TZ" > /etc/timezone
  dpkg-reconfigure -f noninteractive tzdata
  sed -i -e "s#;date.timezone.*#date.timezone = ${TZ}#g" /etc/php5/fpm/php.ini
fi

if [[ -z $DEFAULT_PORT ]]; then
  DEFAULT_PORT=8000
fi
sed -i -e "s#DEFAULT_PORT#${DEFAULT_PORT}#" /etc/nginx/sites-enabled/owncloud

# Setup certificates
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
  cp -f /opt/server.* /var/www/owncloud/data/
fi

if [[ -f /var/www/owncloud/data/dhparam.pem ]]; then
  #Copy DH Parameters File
  cp /var/www/owncloud/data/dhparam.pem /opt/dhparam.pem
else
  #Create DH Parameters File
  echo "Creating DH Parameters File."
  echo "This may take up to 30 minutes."
  openssl dhparam -out /opt/dhparam.pem 4096
  cp -f /opt/dhparam.pem /var/www/owncloud/data/
fi

if [[ ! -d /var/www/owncloud/data/config ]]; then
  mkdir /var/www/owncloud/data/config
fi

if [[ -d /var/www/owncloud/config ]]; then
  rm -rf /var/www/owncloud/config
  ln -sf /var/www/owncloud/data/config/ /var/www/owncloud/config
fi

# Add cron job
echo '*/15 * * * * /usr/bin/php -f /var/www/owncloud/cron.php >/dev/null 2>&1' | crontab -u nobody -

chown -R nobody:users /var/www/owncloud