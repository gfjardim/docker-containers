#!/bin/bash

. /opt/default-values.sh

# create default dirs
mkdir -p /config/id /config/log /config/conf /config/bin /config/cache

# move identity out of container, this prevent having to adopt account every time you rebuild the Docker
if [ ! -L "/var/lib/crashplan" ]; then
  rm -rf /var/lib/crashplan
  ln -sf /config/id /var/lib/crashplan
fi

# move log directory out of container
if [ ! -L "/usr/local/crashplan/log" ]; then
  rm -rf /usr/local/crashplan/log
  ln -sf /config/log /usr/local/crashplan/log
fi

# move conf directory out of container
if [[ ! -L "/usr/local/crashplan/conf" ]]; then
  if [ ! -f "/config/conf/default.service.xml" ]; then
    cp -rf /usr/local/crashplan/conf/* /config/conf/
  fi
  rm -rf /usr/local/crashplan/conf
  ln -sf /config/conf /usr/local/crashplan/conf
fi

# move run.conf out of container
# adjust RAM as described here: http://support.code42.com/CrashPlan/Latest/Troubleshooting/CrashPlan_Runs_Out_Of_Memory_And_Crashes
if [[ ! -L "/usr/local/crashplan/bin" ]]; then
  if [ ! -f "/config/bin/run.conf" ]; then
    cp -rf /usr/local/crashplan/bin/run.conf /config/bin/run.conf
  fi
  rm -rf /usr/local/crashplan/bin
  ln -sf /config/bin /usr/local/crashplan/bin
fi

# VNC credentials
if [ ! -f "${VNC_CREDENTIALS}" -a -n "${VNC_PASSWD}" ]; then
  /opt/vncpasswd/vncpasswd.py -f "${VNC_CREDENTIALS}" -e "${VNC_PASSWD}"
fi

# CrashPlan
if [ -f "/config/conf/my.service.xml" ]; then
  sed -i -e "s#<location>\([^:]*\):[^<]*</location>#<location>\1:${BACKUP_PORT}</location>#g" \
         -e "s#<servicePort>[^<]*</servicePort>#<servicePort>${SERVICE_PORT}</servicePort>#g" \
         -e "s#<upgradePath>[^<]*</upgradePath>#<upgradePath>upgrade</upgradePath>#g" /config/conf/my.service.xml

  if grep "<cachePath>.*</cachePath>" /config/conf/my.service.xml > /dev/null; then
    sed -i "s|<cachePath>.*</cachePath>|<cachePath>/config/cache</cachePath>|g" /config/conf/my.service.xml
  else
    sed -i "s|<backupConfig>|<backupConfig>\n\t\t\t<cachePath>/config/cache</cachePath>|g" /config/conf/my.service.xml
  fi
fi

# Allow CrashPlan to restart
echo -e '#!/bin/sh\n/etc/init.d/crashplan restart' > /usr/local/crashplan/bin/restartLinux.sh
chmod +x /usr/local/crashplan/bin/restartLinux.sh

# Move old logs to /config/log/
find /config -maxdepth 1 -type f -iname "*.log" -exec mv '{}' /config/log/ \;

# Disable MPROTECT for grsec on java executable (for hardened kernels)
if [ -n "${HARDENED}" -a ! -f "/tmp/.hardened" ]; then
  echo "Disable MPROTECT for grsec on JAVA executable."
  source /usr/local/crashplan/install.vars
  paxctl -c "${JAVACOMMON}"
  paxctl -m "${JAVACOMMON}"
  touch /tmp/.hardened
fi
