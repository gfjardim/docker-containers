#!/bin/bash
umask 000

if [[ $(cat /etc/timezone) != $TZ ]] ; then
  echo "$TZ" > /etc/timezone
  dpkg-reconfigure -f noninteractive tzdata
fi

# Check if nzbget.conf exists. If not, copy in the sample config
if [ -f /config/nzbget.conf ]; then
  echo "Using existing nzbget.conf file."
else
  echo "Creating nzbget.conf from template."
  cp /opt/nzbget/webui/nzbget.conf.template /config/nzbget.conf
  sed -i -e "s#\(MainDir=\).*#\1/downloads#g" /config/nzbget.conf
  sed -i -e "s#\(ControlIP=\).*#\10.0.0.0#g" /config/nzbget.conf
  sed -i -e "s#\(UMask=\).*#\1000#g" /config/nzbget.conf
  sed -i -e "s#\(ScriptDir=\).*#\1/config/ppscripts#g" /config/nzbget.conf
  sed -i -e "s#\(QueueDir=\).*#\1/config/queue#g" /config/nzbget.conf
  sed -i -e "s#\(SecureControl=\).*#\1yes#g" /config/nzbget.conf
  sed -i -e "s#\(SecurePort=\).*#\16791#g" /config/nzbget.conf
  mkdir -p /downloads/dst
fi

# Set Docker environment settings to NZBGet config
sed -i -e "s#\(WebDir=\).*#\1/opt/nzbget/webui#g" /config/nzbget.conf
sed -i -e 's#\(ConfigTemplate=\).*#\1/opt/nzbget/webui/nzbget.conf.template#g' /config/nzbget.conf
sed -i -e "s#\(LogFile=\).*#\1/config/log/nzbget.log#g" /config/nzbget.conf
sed -i -e "s#\(SecureCert=\).*#\1/config/ssl/nzbget.crt#g" /config/nzbget.conf
sed -i -e "s#\(SecureKey=\).*#\1/config/ssl/nzbget.key#g" /config/nzbget.conf

# Create TLS certs
if [[ ! -f /config/ssl/nzbget.key ]]; then
  mkdir -p /config/ssl
  openssl req -x509 -nodes -days 3650 -newkey rsa:2048 -keyout /config/ssl/nzbget.key -out /config/ssl/nzbget.crt -subj "/O=SOHO/OU=HOME/CN=yourhome.com"
fi

# # Embed the update package-info
# if [[ ! -f /usr/share/nzbget/webui/package-info.json ]]; then
#   sed -i -e "s#GIT_REPO#${GIT_REPO}#g" /opt/package-info.json
#   cp /opt/package-info.json /usr/share/nzbget/webui/
# fi

# Verify and create some directories
if [[ ! -e /config/queue ]]; then
  mkdir -p /config/queue
fi

if [[ ! -e /config/log ]]; then
  mkdir -p /config/log
fi

if [[ ! -e /config/ppscripts ]]; then
  mkdir -p /config/ppscripts
fi

# install last version of ppscripts
if [[ ! -f /tmp/ppscripts_installed ]]; then

  # Clean some old files
  cd /config/ppscripts/
  rm DeleteSamples.py NotifyXBMC.py  ResetDateTime.py  SafeRename.py  flatten.py passwordList.py

  # Add some post-processing scripts
  # nzbToMedia
  echo "Downloading nzbToMedia."
  rm -rf /config/ppscripts/nzbToMedia
  mkdir -p /config/ppscripts/nzbToMedia
  wget -nv https://github.com/clinton-hall/nzbToMedia/archive/master.tar.gz -O - | tar --strip-components 1 -C /config/ppscripts/nzbToMedia -zxf -

  # Misc Clinton Hall scripts
  rm -rf /config/ppscripts/Misc
  mkdir -p /config/ppscripts/Misc
  wget -nv https://github.com/clinton-hall/GetScripts/archive/master.tar.gz -O - | tar -zxf - --strip-components 1 -C /config/ppscripts/Misc --wildcards --no-anchored '*.py'

  # Videosort
  echo "Downloading videosort."
  rm -rf /config/ppscripts/videosort
  mkdir -p /config/ppscripts/videosort
  wget -nv https://github.com/nzbget/VideoSort/archive/master.tar.gz -O - | tar -zx --strip-components 1 -C /config/ppscripts/videosort

  # NotifyXBMC.py
  echo "Downloading Notify NZBGet."
  echo "Search for help at http://forum.nzbget.net/viewtopic.php?f=8&t=1639."
  rm -rf /config/ppscripts/Notify
  mkdir -p /config/ppscripts/Notify
  wget -nv https://github.com/caronc/nzbget-notify/archive/master.tar.gz -O - | tar -zx --strip-components 1 -C /config/ppscripts/Notify

  touch /tmp/ppscripts_installed
fi

# Ensure permissions
chown -R nobody:users /config /opt/nzbget
chmod -R 777 /etc/service /etc/my_init.d /tmp