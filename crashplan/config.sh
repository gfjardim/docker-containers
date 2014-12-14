#!/bin/bash

# Fix the timezone
if [[ $(cat /etc/timezone) != $TZ ]] ; then
  echo "$TZ" > /etc/timezone
  dpkg-reconfigure -f noninteractive tzdata
fi

# move identity out of container, this prevents having to adopt account every time you rebuild the Docker
if [[ ! -d /config/id ]]; then
  mkdir -p /config/id
fi
rm -rf /var/lib/crashplan
ln -sf /config/id /var/lib/crashplan

# move cache directory out of container, this prevents re-synchronization every time you rebuild the Docker
if [[ ! -d /config/cache ]]; then
  mkdir -p /config/cache
fi
rm -rf /usr/local/crashplan/cache
ln -sf /config/cache /usr/local/crashplan/cache

# move log directory out of container
if [[ ! -d /config/log ]]; then
  mkdir -p /config/log
fi
rm -rf /usr/local/crashplan/log
ln -sf /config/log /usr/local/crashplan/log

# move conf directory out of container
if [[ ! -d /config/conf ]]; then
  mkdir -p /config/conf
  if [[ ! -f /config/conf/default.service.xml ]]; then
    cp -rf /usr/local/crashplan/conf/* /config/conf/
  fi
fi
rm -rf /usr/local/crashplan/conf
ln -sf /config/conf /usr/local/crashplan/conf

# move run.conf out of container
# adjust RAM as described here: http://support.code42.com/CrashPlan/Latest/Troubleshooting/CrashPlan_Runs_Out_Of_Memory_And_Crashes
if [[ ! -d /config/bin ]]; then
  mkdir -p /config/bin
  if [[ ! -f /config/bin/run.conf ]]; then
    cp /usr/local/crashplan/bin/run.conf /config/bin/
  fi
fi
rm -rf /usr/local/crashplan/bin/run.conf
ln -sf /config/bin/run.conf /usr/local/crashplan/bin/run.conf

chown -R nobody:users /config
