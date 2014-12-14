#!/bin/bash

#########################################
##        ENVIRONMENTAL CONFIG         ##
#########################################

# Configure user nobody to match unRAID's settings
usermod -u 99 nobody
usermod -g 100 nobody
usermod -d /home nobody
chown -R nobody:users /home

# Disable SSH
rm -rf /etc/service/sshd /etc/my_init.d/00_regen_ssh_host_keys.sh

#########################################
##    REPOSITORIES AND DEPENDENCIES    ##
#########################################

# Repositories
add-apt-repository "deb http://us.archive.ubuntu.com/ubuntu/ trusty universe multiverse"
add-apt-repository "deb http://us.archive.ubuntu.com/ubuntu/ trusty-updates universe multiverse"

# Use mirrors
sed -i -e "s#http://[^\s]*archive.ubuntu[^\s]* #mirror://mirrors.ubuntu.com/mirrors.txt #g" /etc/apt/sources.list

# Install Dependencies
apt-get update -qq
apt-get install -qy wget

# Install Syncthing
latest_release=$(curl -k -L https://github.com/syncthing/syncthing/releases/latest 2>/dev/null)
regex="(/syncthing/syncthing/releases/download/[^\/]*/syncthing-linux-amd64[^\"]*)"
if [[ $latest_release =~ $regex ]]; then
  URL="https://github.com"${BASH_REMATCH[1]}
  echo "Updating Syncthing"
  rm -rf /opt/syncthing
  echo "Downloading package from: ${URL}"
  mkdir -p /opt/syncthing && wget -nv -O - "${URL}" | tar -xzf - --strip-components=1 -C /opt/syncthing
else
  exit 0
fi

# Clean APT install files
apt-get clean -y
rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
