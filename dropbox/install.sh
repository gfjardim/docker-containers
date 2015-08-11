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
##    REPOSITORIES AND DEPENDENCIES    ##
#########################################

# Repositories
add-apt-repository "deb http://us.archive.ubuntu.com/ubuntu/ trusty universe multiverse"
add-apt-repository "deb http://us.archive.ubuntu.com/ubuntu/ trusty-updates universe multiverse"

# Install Dependencies
apt-get update -qq
apt-get install -qy wget ruby

#########################################
##  FILES, SERVICES AND CONFIGURATION  ##
#########################################
# CONFIG
cat <<'EOT' > /etc/my_init.d/config.sh
#!/bin/bash
# Fix the timezone
if [[ $(cat /etc/timezone) != $TZ ]] ; then
  echo "$TZ" > /etc/timezone
  dpkg-reconfigure -f noninteractive tzdata
fi

if [ -z "$STATUS" ]; then
  echo "Continous console status not requested"
  [ -d /etc/service/DropboxStatus ] && rm -r /etc/service/DropboxStatus
fi

exit 0
EOT

# Dropbox
mkdir -p /etc/service/Dropbox
cat <<'EOT' > /etc/service/Dropbox/run
#!/bin/bash
umask 000
chown -R nobody:users /home

#  Dropbox did not shutdown properly? Remove files.
[ ! -e "/home/.dropbox/command_socket" ] || rm /home/.dropbox/command_socket
[ ! -e "/home/.dropbox/iface_socket" ]   || rm /home/.dropbox/iface_socket
[ ! -e "/home/.dropbox/unlink.db" ]      || rm /home/.dropbox/unlink.db
[ ! -e "/home/.dropbox/dropbox.pid" ]    || rm /home/.dropbox/dropbox.pid

exec /sbin/setuser nobody /home/.dropbox-dist/dropboxd
EOT

# DropboxStatus
mkdir -p /etc/service/DropboxStatus
cat <<'EOT' > /etc/service/DropboxStatus/run
#!/bin/bash                                                                                   
exec 2>&1 

# Wait for Dropbox Daemon to start.
[ -e /home/.dropbox/iface_socket ] || exit 1


# start DropboxStatus
exec /sbin/setuser nobody /usr/bin/dropbox_status
EOT

chmod +x /etc/service/*/run /etc/my_init.d/*

#########################################
##             INSTALLATION            ##
#########################################

# Install Dropbox
wget -nv -O - "https://www.dropbox.com/download?plat=lnx.x86_64" | tar -xzf - -C /home

# Install DropboxStatus ruby script
cat << 'EOT' > /usr/bin/dropbox_status
#!/usr/bin/ruby
# dropbox status in console.
# http://dl.getdropbox.com/u/76825/dropbox_status.rb
# http://d.hatena.ne.jp/urekat/20081124/1227498262
# http://forums.getdropbox.com/tags.php?tag=cli

require "socket"
require "pathname"

iface_sock_path   = File.expand_path("/home/.dropbox/iface_socket")
s_iface   = UNIXSocket.open(iface_sock_path)

def cmd_done(lines)
  case lines[0]
  when "change_to_menu"
    # "active\ttrue"
  when "change_state"
    # "new_state\t1"
  when "refresh_tray_menu"
    # "active\ttrue"
  when "shell_touch"
    puts "[#{Time.now.inspect}] "+lines[1].gsub(/^path\t/, "")
  when "bubble"
    s = "[#{Time.now.inspect}]--------"
    puts s
    lines[1,lines.size-2].each do |l|
      puts "    "+l
    end
    puts "-" * s.size
  else
    puts "unknown:"+lines.inspect
  end
end

lines = []
loop{
  l = s_iface.gets
  break unless l
  l.strip!
  lines << l
  if l=="done"
    cmd_done(lines)
    lines = []
  end
}
EOT

chmod +x /usr/bin/dropbox_status

#########################################
##                 CLEANUP             ##
#########################################

# Clean APT install files
apt-get clean -y
rm -rf /var/lib/apt/lists/* /var/cache/* /var/tmp/*

