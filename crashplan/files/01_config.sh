#!/bin/bash
_link() {
  if [[ -L ${2} && $(readlink ${2}) == ${1} ]]; then
    return 0
  fi
  if [[ ! -e ${1} ]]; then
    if [[ -d ${2} ]]; then
      mkdir -p "${1}"
      pushd ${2} &>/dev/null
      find . -type f -exec cp --parents '{}' "${1}/" \;
      popd &>/dev/null
    elif [[ -f ${2} ]]; then
      if [[ ! -d $(dirname ${1}) ]]; then
        mkdir -p $(dirname ${1})
      fi
      cp -f "${2}" "${1}"
    else
      mkdir -p "${1}"
    fi
  fi
  if [[ -d ${2} ]]; then
    rm -rf "${2}"
  elif [[ -f ${2} || -L ${2} ]]; then
    rm -f "${2}"
  fi
  if [[ ! -d $(dirname ${2}) ]]; then
    mkdir -p $(dirname ${2})
  fi
  ln -sf ${1} ${2}
}

# move identity out of container, this prevent having to adopt account every time you rebuild the Docker
_link /config/id /var/lib/crashplan

# move cache directory out of container, this prevents re-synchronization every time you rebuild the Docker
_link /config/cache /usr/local/crashplan/cache

# move log directory out of container
_link /config/log /usr/local/crashplan/log

# move conf directory out of container
if [[ ! -f /config/conf/default.service.xml ]]; then
  rm -rf /config/conf
fi
_link /config/conf /usr/local/crashplan/conf

# move run.conf out of container
# adjust RAM as described here: http://support.code42.com/CrashPlan/Latest/Troubleshooting/CrashPlan_Runs_Out_Of_Memory_And_Crashes
if [[ ! -f /config/bin/run.conf ]]; then
  rm -rf /config/bin
fi
_link /config/bin /usr/local/crashplan/bin

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
sed -i -e "s#<location>\([^:]*\):[^<]*</location>#<location>\1:${TCP_PORT_4242}</location>#g" /config/conf/my.service.xml
sed -i -e "s#<servicePort>[^<]*</servicePort>#<servicePort>${TCP_PORT_4243}</servicePort>#g"  /config/conf/my.service.xml
sed -i -e "s#<upgradePath>[^<]*</upgradePath>#<upgradePath>upgrade</upgradePath>#g"           /config/conf/my.service.xml

# Set VNC password if requested:
if [[ -n $VNC_PASSWD ]]; then
  sed -i -e "s#SECURITY#-SecurityTypes TLSVnc,VncAuth -PasswordFile /nobody/.vnc_passwd#g" /etc/service/tigervnc/run
  /opt/vncpasswd/vncpasswd.py -f /nobody/.vnc_passwd -e "${VNC_PASSWD}"
else
  sed -i -e "s#SECURITY#-SecurityTypes None#g" /etc/service/tigervnc/run
fi