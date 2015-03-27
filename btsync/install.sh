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
rm -rf /etc/service/sshd /etc/my_init.d/00_regen_ssh_host_keys.sh

#########################################
##  FILES, SERVICES AND CONFIGURATION  ##
#########################################
#config
cat <<'EOT' > /etc/my_init.d/config.sh
#!/bin/bash
if [[ $(cat /etc/timezone) != $TZ ]] ; then
  echo "$TZ" > /etc/timezone
  DEBIAN_FRONTEND="noninteractive" dpkg-reconfigure -f noninteractive tzdata
fi
EOT

# btsync
mkdir -p /etc/service/btsync
cat <<'EOT' > /etc/service/btsync/run
#!/bin/bash
umask 000
[[ ! -f /config/btsync.conf ]] && cp /tmp/btsync.conf /config/
[[ ! -d /config/.sync ]] && mkdir -p /config/.sync
chown -R nobody:users /opt/btsync /config
exec /sbin/setuser nobody /opt/btsync/btsync --nodaemon --config "/config/btsync.conf"
EOT

cat <<'EOT' > /tmp/btsync.conf
{
  "device_name": "unRAID",
  "listening_port" : 5555, 
  "storage_path" : "/config/.sync",
  "use_upnp" : false,

  "download_limit" : 0,
  "upload_limit" : 0,
  "webui" :
  {
    "listen" : "0.0.0.0:8888"
  }
}
EOT

chmod -R +x /etc/service/ /etc/my_init.d/

#########################################
##    REPOSITORIES AND DEPENDENCIES    ##
#########################################

# Repositories
add-apt-repository "deb http://us.archive.ubuntu.com/ubuntu/ trusty universe multiverse"
add-apt-repository "deb http://us.archive.ubuntu.com/ubuntu/ trusty-updates universe multiverse"

# Install Dependencies
# apt-get update -qq
# apt-get install -qy wget

#########################################
##             INSTALLATION            ##
#########################################

# Install BTSync
mkdir -p /opt/btsync
curl -s -k -L "https://download-cdn.getsyncapp.com/stable/linux-x64/BitTorrent-Sync_x64.tar.gz" |  tar -xzf - -C /opt/btsync


#########################################
##                 CLEANUP             ##
#########################################

# Clean APT install files
apt-get clean -y
rm -rf /var/lib/apt/lists/* /var/cache/* /var/tmp/*
