#!/bin/bash
umask 000

# install last used version
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
  sed -i -e "s#\(LogFile=\).*#\1/config/log/nzbget.logs#g" /config/nzbget.conf
  mkdir -p /downloads/dst
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

# Add some post-processing scripts
# nzbToMedia
if [[ ! -e /config/ppscripts/nzbToMedia ]]; then
  echo "Downloading nzbToMedia."
  mkdir -p /config/ppscripts/nzbToMedia
  wget -nv https://github.com/clinton-hall/nzbToMedia/archive/master.tar.gz -O - | tar --strip-components 1 -C /config/ppscripts/nzbToMedia -zxf -
fi

# Videosort
if [[ ! -e /config/ppscripts/videosort ]]; then
  echo "Downloading videosort."
  mkdir -p /config/ppscripts/videosort
  wget -nv http://sourceforge.net/projects/nzbget/files/ppscripts/videosort/videosort-ppscript-4.0.zip/download -O /config/ppscripts/videosort-ppscript-4.0.zip
  unzip -qq /config/ppscripts/videosort-ppscript-4.0.zip
  rm /config/ppscripts/videosort-ppscript-4.0.zip
fi

# NotifyXBMC.py
if [[ ! -e /config/ppscripts/NotifyXBMC.py ]]; then
  echo "Downloading NotifyXBMC."
  wget -nv http://nzbget.net/forum/download/file.php?id=193 -O /config/ppscripts/NotifyXBMC.py
fi

# Fix permissions
chown -R nobody:users /config
chmod 777 /tmp
