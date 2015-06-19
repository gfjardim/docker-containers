#!/bin/bash

#########################################
##        ENVIRONMENTAL CONFIG         ##
#########################################

# Configure user nobody to match unRAID's settings
export DEBIAN_FRONTEND="noninteractive"
usermod -u 99 nobody
usermod -g 100 nobody
usermod -d /home nobody
chown -R nobody:users /home

# Disable SSH
rm -rf /etc/service/sshd /etc/service/cron /etc/service/syslog-ng /etc/my_init.d/00_regen_ssh_host_keys.sh

#########################################
##  FILES, SERVICES AND CONFIGURATION  ##
#########################################
# pyload
mkdir -p /etc/service/pyload
cat <<'EOT' > /etc/service/pyload/run
#!/bin/bash
umask 000
if [[ $(cat /etc/timezone) != $TZ ]] ; then
  echo "$TZ" > /etc/timezone
  DEBIAN_FRONTEND="noninteractive" dpkg-reconfigure -f noninteractive tzdata
fi

if [[ ! -e /config/pyload.conf ]]; then
  cp -rf /tmp/pyload.conf /tmp/plugin.conf /tmp/files.version /tmp/files.db /config/
fi

chown -R nobody:users /config /opt/pyload

exec /sbin/setuser nobody python /opt/pyload/pyLoadCore.py --configdir=/config
EOT

chmod -R +x /etc/service/ /etc/my_init.d/

#########################################
##    REPOSITORIES AND DEPENDENCIES    ##
#########################################

# Repositories
add-apt-repository "deb http://us.archive.ubuntu.com/ubuntu/ trusty universe multiverse"
add-apt-repository "deb http://us.archive.ubuntu.com/ubuntu/ trusty-updates universe multiverse"
curl -skL -o /etc/apt/sources.list http://tinyurl.com/lm2vf9a

# Install Dependencies
apt-get update -q
apt-get install -qy python-crypto python-pycurl tesseract-ocr git rhino unrar

#########################################
##             INSTALLATION            ##
#########################################

# Install Pyload
mkdir -p /opt/pyload
curl -s -k -L "https://github.com/pyload/pyload/archive/stable.tar.gz" | tar -xz --strip 1 -C /opt/pyload

#########################################
##                 CLEANUP             ##
#########################################

# Clean APT install files
apt-get clean -y
rm -rf /var/lib/apt/lists/* /var/cache/* /var/tmp/*
