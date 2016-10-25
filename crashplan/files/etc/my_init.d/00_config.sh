#!/bin/bash

# Fix the timezone
if [[ $(cat /etc/timezone) != $TZ ]] ; then
  ln -sf "/usr/share/zoneinfo/$TZ" /etc/localtime
  dpkg-reconfigure -f noninteractive tzdata
fi

# Reconfigure user ID/GID if necessary
mkdir -p /nobody
USERID=${USER_ID:-99}
GROUPID=${GROUP_ID:-100}
groupmod -g $GROUPID users
usermod -u $USERID nobody
usermod -g $GROUPID nobody
usermod -d /nobody nobody
chown -R nobody:users /nobody/
