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
