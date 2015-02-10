#!/bin/bash

# Fix the timezone
if [[ $TZ ]]; then
  if [[ $(cat /etc/timezone) != $TZ ]] ; then
    echo "Updating timezone to '$TZ'"
    echo "$TZ" > /etc/timezone
    dpkg-reconfigure -f noninteractive tzdata
  fi
fi

# Updating UID/GID for nobody
if [[ ! $USERMAP_UID ]]; then
    echo "Using default uid of 'nobody' $(id -u nobody)"
else
    echo "Updating 'nobody' uid to $USERMAP_UID"
    usermod -u ${USERMAP_UID} nobody
fi
if [[ ! $USERMAP_GID ]]; then
    echo "Using default gid of 'nobody' $(id -g nobody)"
else
    echo "Updating 'nobody' gid to $USERMAP_GID"
    usermod -g ${USERMAP_GID} nobody
fi

