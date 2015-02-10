#!/bin/bash

# Fix the timezone
if [[ $(cat /etc/timezone) != $TZ ]] ; then
  echo "$TZ" > /etc/timezone
  dpkg-reconfigure -f noninteractive tzdata
fi

# Updating UID/GID for nobody
if [ -z "$USERMAP_UID" ]; then
    echo "Using default uid of 'nobody' $(id -u nobody)"
else
    echo "Updating 'nobody' uid to $USERMAP_UID"
    usermod -u ${USERMAP_UID} nobody
fi
if [ -z "$USERMAP_GID" ]; then
    echo "Using default gid of 'nobody' $(id -g nobody)"
else
    echo "Updating 'nobody' gid to $USERMAP_GID"
    usermod -g ${USERMAP_GID} nobody
fi

