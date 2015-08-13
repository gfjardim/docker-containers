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
##    REPOSITORIES AND DEPENDENCIES    ##
#########################################

# Repositories
add-apt-repository "deb http://us.archive.ubuntu.com/ubuntu/ trusty universe multiverse"
add-apt-repository "deb http://us.archive.ubuntu.com/ubuntu/ trusty-updates universe multiverse"

# Install Dependencies
apt-get update -qq
apt-get install -qy supervisor

#########################################
##  FILES, SERVICES AND CONFIGURATION  ##
#########################################
# CONFIG
cat <<'EOT' > /opt/config.sh
#!/bin/bash
# Fix the timezone
if [[ $(cat /etc/timezone) != $TZ ]] ; then
  echo "$TZ" > /etc/timezone
  dpkg-reconfigure -f noninteractive tzdata
fi
chown -R nobody:users /home
sleep 5
exit 0
EOT

# Dropbox
cat <<'EOT' > /opt/dropbox.sh
#!/bin/bash

#  Dropbox did not shutdown properly? Remove files.
[ ! -e "/home/.dropbox/command_socket" ] || rm /home/.dropbox/command_socket
[ ! -e "/home/.dropbox/iface_socket" ]   || rm /home/.dropbox/iface_socket
[ ! -e "/home/.dropbox/unlink.db" ]      || rm /home/.dropbox/unlink.db
[ ! -e "/home/.dropbox/dropbox.pid" ]    || rm /home/.dropbox/dropbox.pid

/home/.dropbox-dist/dropboxd
EOT

# DropboxStatus
cat <<'EOT' > /opt/dropbox_status.sh
#!/bin/bash

if [ "$STATUS" != "Yes" ]; then
  echo "Continous console status not requested"
  sleep 5;
  exit 0
else
  while [ ! -e "/home/.dropbox/iface_socket" ]; do sleep 1; done
  /opt/dropbox_status.py
fi
EOT

cat <<'EOT' > /etc/supervisor.conf
[supervisord]
nodaemon=true
umask = 000

[program:config]
priority = 1
startsecs = 0
autorestart = False
command = /opt/config.sh

[program:Dropbox]
priority = 998
user = nobody
group = users
directory= /home
environment = HOME="/home"
startsecs = 1
autorestart = False
command = /opt/dropbox.sh
stdout_logfile=/dev/stdout
stdout_logfile_maxbytes=0
stderr_logfile=/dev/stderr
stderr_logfile_maxbytes=0

[program:DropboxStatus]
priority = 999
user = nobody
directory=/home
environment = HOME="/home"
startsecs = 1
autorestart = False
command = /opt/dropbox_status.sh
stdout_logfile=/dev/stdout
stdout_logfile_maxbytes=0
stderr_logfile=/dev/stderr
stderr_logfile_maxbytes=0
EOT

mv /tmp/dropbox_status.py /opt/dropbox_status.py
chmod +x /opt/*.sh /opt/dropbox_status.py

#########################################
##             INSTALLATION            ##
#########################################

# Install Dropbox
curl -k -L "https://www.dropbox.com/download?plat=lnx.x86_64" | tar -xzf - -C /home
chown -R nobody:users /home

#########################################
##                 CLEANUP             ##
#########################################

# Clean APT install files
apt-get clean -y
rm -rf /var/lib/apt/lists/* /var/cache/* /var/tmp/*

