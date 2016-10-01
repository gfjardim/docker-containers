#!/bin/bash

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
    cp -rf /usr/local/crashplan/bin/* /config/bin/
  fi
  rm -rf /usr/local/crashplan/bin
  ln -sf /config/bin /usr/local/crashplan/bin
fi

# Load default values if empty
TCP_PORT_4239=${TCP_PORT_4239:-4239}
TCP_PORT_4280=${TCP_PORT_4280:-4280} 
TCP_PORT_4242=${TCP_PORT_4242:-4242}
TCP_PORT_4243=${TCP_PORT_4243:-4243}

# noVNC
sed -i -e "s#WEB_PORT#${TCP_PORT_4280}#g" /etc/service/novnc/run
sed -i -e "s#VNC_PORT#${TCP_PORT_4239}#g" /etc/service/novnc/run

# TigerVNC
sed -i -e "s#VNC_PORT#${TCP_PORT_4239}#g" /etc/service/tigervnc/run
if [[ -n $VNC_PASSWD ]]; then
  sed -i -e "s#SECURITY#-SecurityTypes TLSVnc,VncAuth -PasswordFile /nobody/.vnc_passwd#g" /etc/service/tigervnc/run
  /opt/vncpasswd/vncpasswd.py -f /config/.vnc_passwd -e "${VNC_PASSWD}"
else
  sed -i -e "s#SECURITY#-SecurityTypes None#g" /etc/service/tigervnc/run
fi

# CrashPlan
if [ -f "/config/conf/my.service.xml" ]; then
  sed -i -e "s#<location>\([^:]*\):[^<]*</location>#<location>\1:${TCP_PORT_4242}</location>#g" /config/conf/my.service.xml
  sed -i -e "s#<servicePort>[^<]*</servicePort>#<servicePort>${TCP_PORT_4243}</servicePort>#g"  /config/conf/my.service.xml
  sed -i -e "s#<upgradePath>[^<]*</upgradePath>#<upgradePath>upgrade</upgradePath>#g"           /config/conf/my.service.xml
  if grep "<cachePath>.*</cachePath>" /config/conf/my.service.xml > /dev/null; then
    sed -i "s|<cachePath>.*</cachePath>|<cachePath>/config/cache</cachePath>|g" /config/conf/my.service.xml
  else
    sed -i "s|<backupConfig>|<backupConfig>\n\t\t\t<cachePath>/config/cache</cachePath>|g" /config/conf/my.service.xml
  fi
fi
