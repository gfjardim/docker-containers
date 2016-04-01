#!/bin/bash
sv_running() {
  state=$(sv status $1|cut -d: -f1)
  if [[ $state == run ]]; then
    return 0
  else
    return 1
  fi
}

while [ 1 ]; do
  if sv_running nginx && sv_running php-fpm && sv_running mariadb; then
    if [[ ! -f /etc/service/owncloud/down ]]; then

      # Update ownCloud
      echo "NOTICE: ownCloud will now update."
      sudo -u nobody -s /bin/bash -c "php /var/www/owncloud/occ upgrade"
      # Add necessary config options
      php /opt/fix_config.php

      # Mark as updated, and disable this service
      touch /etc/service/owncloud/down
      echo "Update done, quitting."
      sv stop owncloud >/dev/null 2>&1
    fi
  fi
  sleep 1
done