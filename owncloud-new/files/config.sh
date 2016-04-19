#!/bin/bash

# Create directories
mkdir -p /config/config /config/db /config/apps /config/data /config/tmp

# Move old config
if [ -f "/config/server.key" ]; then
  mv /config/server.key /config/config/server.key
  find /config -mindepth 1 -maxdepth 1 ! \( -name "apps" -o -name "config" -o -name "tmp" -o -name "data" -o -name "db" \) -exec mv '{}' /config/data/ \;
fi
if [ -f "/config/server.pem" ]; then
  mv /config/server.pem /config/config/server.pem
fi
if [ -f "/config/dhparam.pem" ]; then
  mv /config/dhparam.pem /config/config/dhparam.pem
fi

# Setup certificates
if [[ -f /config/config/server.key && -f /config/config/server.pem ]]; then
  echo "Found pre-existing certificate, using it."
else
  if [[ -z $SUBJECT ]]; then 
    SUBJECT="/C=US/ST=CA/L=Carlsbad/O=Lime Technology/OU=unRAID Server/CN=yourhome.com"
  fi
  echo -e "No pre-existing certificate found, generating a new one with subject: \n$SUBJECT"
  openssl req -new -x509 -days 3650 -nodes -out /config/config/server.pem -keyout /config/config/server.key \
          -subj "$SUBJECT"
fi

if [[ ! -f /config/config/dhparam.pem ]]; then
  #Create DH Parameters File
  echo "Creating DH Parameters File."
  echo "This may take up to 30 minutes."
  openssl dhparam -out /config/config/dhparam.pem 4096
fi

if [[ -d /var/www/owncloud/config ]]; then
  rm -rf /var/www/owncloud/config
  ln -sf /config/config/ /var/www/owncloud/config
fi

if [ ! -L "/var/www/owncloud/local_apps" ]; then
  ln -sf /config/apps/ /var/www/owncloud/local_apps
fi

# Add cron job
echo '*/15 * * * * /usr/bin/php -f /var/www/owncloud/cron.php >/dev/null 2>&1' | crontab -u nobody -

chown -R nobody:users /config/