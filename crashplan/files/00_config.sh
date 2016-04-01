#!/bin/bash

# Fix the timezone
if [[ $(cat /etc/timezone) != $TZ ]] ; then
  echo "$TZ" > /etc/timezone
  dpkg-reconfigure -f noninteractive tzdata
fi

# Reconfigure user ID/GID if necessary
USERID=${USER_ID:-99}
GROUPID=${GROUP_ID:-100}
groupmod -g $GROUPID users
usermod -u $USERID nobody
usermod -g $GROUPID nobody
usermod -d /nobody nobody
chown -R nobody:users /nobody/

# Load default values if empty
TCP_PORT_4239=${TCP_PORT_4239:-4239}
TCP_PORT_4242=${TCP_PORT_4242:-4242}
TCP_PORT_4243=${TCP_PORT_4243:-4243} 
TCP_PORT_4280=${TCP_PORT_4280:-4280} 

# noVNC
sed -i -e "s#WEB_PORT#${TCP_PORT_4280}#g" /etc/service/novnc/run
sed -i -e "s#VNC_PORT#${TCP_PORT_4239}#g" /etc/service/novnc/run

# TigerVNC
sed -i -e "s#VNC_PORT#${TCP_PORT_4239}#g" /etc/service/tigervnc/run

# CrashPlan
sed -i -e "s#<location>\([^:]*\):[^<]*</location>#<location>\1:${TCP_PORT_4242}</location>#g" /usr/local/crashplan/conf/my.service.xml
sed -i -e "s#<servicePort>[^<]*</servicePort>#<servicePort>${TCP_PORT_4243}</servicePort>#g" /usr/local/crashplan/conf/my.service.xml

# Set VNC password if requested:
if [[ -n $VNC_PASSWD ]]; then
  sed -i -e "s#SECURITY#-SecurityTypes TLSVnc,VncAuth -PasswordFile /nobody/.vnc_passwd#g" /etc/service/tigervnc/run
  /opt/vncpasswd/vncpasswd.py -f /nobody/.vnc_passwd -e "${VNC_PASSWD}"
else
  sed -i -e "s#SECURITY#-SecurityTypes None#g" /etc/service/tigervnc/run
fi