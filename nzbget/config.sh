#!/bin/bash
umask 000

# install last used version
if [[ ! -f /tmp/last_version_installed ]]; then
  if [[ -d /config/last_version ]]; then
    for file in /config/last_version/* ; do
      dpkg -i $file
    done
  fi
  touch /tmp/last_version_installed
fi

# Fix a potential lack of template config
if [[ -f /usr/share/nzbget/nzbget.conf ]]; then
  cp /usr/share/nzbget/nzbget.conf /usr/share/nzbget/webui/
elif [[ -f /usr/share/nzbget/webui/nzbget.conf ]]; then
  cp /usr/share/nzbget/webui/nzbget.conf /usr/share/nzbget/
fi

# Check if nzbget.conf exists. If not, copy in the sample config
if [ -f /config/nzbget.conf ]; then
  echo "Using existing nzbget.conf file."
else
  echo "Creating nzbget.conf from template."
  cp /usr/share/nzbget/nzbget.conf /config/
  sed -i -e "s#\(MainDir=\).*#\1/downloads#g" /config/nzbget.conf
  sed -i -e "s#\(ControlIP=\).*#\10.0.0.0#g" /config/nzbget.conf
  sed -i -e "s#\(UMask=\).*#\1000#g" /config/nzbget.conf
  sed -i -e "s#\(ScriptDir=\).*#\1/config/ppscripts#g" /config/nzbget.conf
  sed -i -e "s#\(QueueDir=\).*#\1/config/queue#g" /config/nzbget.conf
  sed -i -e "s#\(LogFile=\).*#\1/config/log/nzbget.log#g" /config/nzbget.conf
  sed -i -e "s#\(SecureControl=\).*#\1yes#g" /config/nzbget.conf
  sed -i -e "s#\(SecurePort=\).*#\16791#g" /config/nzbget.conf
  sed -i -e "s#\(SecureCert=\).*#\1/config/ssl/nzbget.crt#g" /config/nzbget.conf
  sed -i -e "s#\(SecureKey=\).*#\1/config/ssl/nzbget.key#g" /config/nzbget.conf
  mkdir -p /downloads/dst
fi

if [[ ! -f /config/ssl/nzbget.key ]]; then
  mkdir -p /config/ssl
  openssl req -x509 -nodes -days 3650 -newkey rsa:2048 -keyout /config/ssl/nzbget.key -out /config/ssl/nzbget.crt -subj "/O=SOHO/OU=HOME/CN=yourhome.com"
fi

# Embed the update package-info
if [[ ! -f /usr/share/nzbget/webui/package-info.json ]]; then
  sed -i -e "s#GIT_USER#${GIT_USER}#g" /opt/package-info.json
  cp /opt/package-info.json /usr/share/nzbget/webui/
fi

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

  # Add some post-processing scripts
  # nzbToMedia
  echo "Downloading nzbToMedia."
  rm -rf /config/ppscripts/nzbToMedia
  mkdir -p /config/ppscripts/nzbToMedia
  wget -nv https://github.com/clinton-hall/nzbToMedia/archive/master.tar.gz -O - | tar --strip-components 1 -C /config/ppscripts/nzbToMedia -zxf -

  # Misc Clinton Hall scripts
  wget -nv https://github.com/clinton-hall/GetScripts/archive/master.tar.gz -O - | tar -zxf - --strip-components 1 -C /config/ppscripts/ --wildcards --no-anchored '*.py'

  # Videosort
  echo "Downloading videosort."
  rm -rf /config/ppscripts/videosort
  mkdir -p /config/ppscripts/videosort
  wget -nv http://sourceforge.net/projects/nzbget/files/ppscripts/videosort/videosort-ppscript-5.0.zip/download -O /config/ppscripts/videosort-ppscript-5.0.zip
  unzip -qq /config/ppscripts/videosort-ppscript-5.0.zip
  rm /config/ppscripts/videosort-ppscript-5.0.zip

  # NotifyXBMC.py
  echo "Downloading NotifyXBMC."
  wget -nv http://nzbget.net/forum/download/file.php?id=193 -O /config/ppscripts/NotifyXBMC.py

  touch /tmp/ppscripts_installed
fi

# Ensure permissions
chown -R nobody:users /config
chmod 777 /tmp


