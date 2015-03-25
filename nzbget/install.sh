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
rm -rf /etc/service/sshd
rm /etc/my_init.d/00_regen_ssh_host_keys.sh

#########################################
##  FILES, SERVICES AND CONFIGURATION  ##
#########################################
# CONFIG
cat <<'EOT' > /etc/my_init.d/config.sh
#!/bin/bash
umask 000

if [[ $(cat /etc/timezone) != $TZ ]] ; then
  echo "$TZ" > /etc/timezone
  dpkg-reconfigure -f noninteractive tzdata
fi

if [[ ! -f /tmp/last_version_installed ]]; then
  if [[ -d /config/last_version ]]; then
    # install last used version
    for file in /config/last_version/* ; do
      dpkg -i $file
    done
  else
    # install current stable version
    /opt/nzbget-update-install.sh
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
  sed -i -e "s#GIT_REPO#${GIT_REPO}#g" /opt/package-info.json
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
EOT

# NZBGET
mkdir /etc/service/nzbget
cat <<'EOT' > /etc/service/nzbget/run
#!/bin/bash
umask 000
if [[ -z $(pgrep nzbget) ]]; then /sbin/setuser nobody /usr/bin/nzbget -c /config/nzbget.conf -D; fi
while [ $(pgrep nzbget) ]; do sleep 1; done
EOT

cat <<'EOT' > /etc/service/nzbget/finish
#!/bin/bash
umask 000
/sbin/setuser nobody /usr/bin/nzbget -c /config/nzbget.conf -Q
EOT

# NZBGET UPDATE
mkdir /etc/service/update_service
cat <<'EOT' > /etc/service/update_service/run
#!/bin/bash
while sleep 5; do
    if [[ -f /tmp/update.sh ]]; then
        echo "Update found, updating."
        sv stop nzbget
        /bin/bash /tmp/update.sh
        rm /tmp/update.sh
        sv start nzbget
    fi
done
EOT

cat <<'EOT' > /opt/package-info.json
NZBGet.PackageInfo = {
    "update-info-link": "https://raw.githubusercontent.com/GIT_REPO/master/nzbget-update-info.json",
    "install-script": "/opt/nzbget-update-install.sh"
}
EOT

cat <<'EOT' > /opt/nzbget-update-install.sh
#!/bin/bash
NZBUP_BRANCH=${NZBUP_BRANCH:-STABLE}

URL="https://raw.githubusercontent.com/${GIT_REPO}/master"

echo "Installing ${NZBUP_BRANCH}"

echo "Downloading new version..."
wget -q --no-check-certificate "${URL}/nzbget-${NZBUP_BRANCH}-amd64.deb" -O /tmp/nzbget-update.deb
if [[ $? -ne 0 ]]; then
    echo "[ERROR] Download failed"
    exit 1
else
    echo "Downloading new version...OK";
fi

echo "Downloading libpar2-1..."
wget -q --no-check-certificate "${URL}/libpar2-1_0.4-3patched_amd64.deb" -O /tmp/libpar2-1_0.4-3patched_amd64.deb
if [[ $? -ne 0 ]]; then
    echo "[ERROR] Download failed"
    exit 1
else
    echo "Downloading libpar2-1...OK";
fi

# Backing up downloaded files
rm -rf /config/last_version
mkdir -p /config/last_version
cp /tmp/nzbget-update.deb /tmp/libpar2-1_0.4-3patched_amd64.deb /config/last_version/

echo "Restarting NzbGet..."

# Write the update.sh script 
cat <<'EOS' > /tmp/update.sh

# Make a backup
regex=".*?:.?(.*?)"
if [[ $(nzbget -v) =~ $regex ]]; then
        VERSION=${BASH_REMATCH[1]}
fi
bkp="/config/backup/nzbget-$VERSION-$(date +'%m-%d-%Y').conf"
mkdir -p /config/backup
cp /config/nzbget.conf $bkp 

# Installing the update
dpkg -P nzbget
dpkg -i /tmp/nzbget-update.deb
rm -f /tmp/nzbget-update.deb

# Update libpar2-1
dpkg -P libpar2-1
dpkg -i /tmp/libpar2-1_0.4-3patched_amd64.deb
rm -f /tmp/libpar2-1_0.4-3patched_amd64.deb

# Run firstrun.sh
/etc/my_init.d/firstrun.sh
EOS
EOT

chmod -R +x /etc/service/ /etc/my_init.d/ /opt/nzbget-update-install.sh

#########################################
##    REPOSITORIES AND DEPENDENCIES    ##
#########################################

# Repositories
add-apt-repository "deb http://us.archive.ubuntu.com/ubuntu/ trusty universe multiverse"
add-apt-repository "deb http://us.archive.ubuntu.com/ubuntu/ trusty-updates universe multiverse"
apt-add-repository ppa:modriscoll/nzbget
add-apt-repository ppa:mc3man/trusty-media

# Use mirrors
sed -i -e "s#http://[^\s]*archive.ubuntu[^\s]* #mirror://mirrors.ubuntu.com/mirrors.txt #g" /etc/apt/sources.list

# Install Dependencies
apt-get update -qq
apt-get install -qy libxml2 \
                    sgml-base \
                    libsigc++-2.0-0c2a \
                    xml-core \
                    javascript-common \
                    libjs-jquery \
                    libjs-jquery-metadata \
                    libjs-jquery-tablesorter \
                    libjs-twitter-bootstrap \
                    libpython-stdlib \
                    python \
                    ffmpeg \
                    wget \
                    unzip \
                    p7zip \
                    nzbget

# Update unrar to the last version
wget http://www.rarlab.com/rar/rarlinux-x64-5.2.1b2.tar.gz -O - |tar zx --strip-components=1 -C /usr/bin/ rar/unrar

#########################################
##                 CLEANUP             ##
#########################################

# Clean APT install files
apt-get clean -y
rm -rf /var/lib/apt/lists/* /var/cache/* /var/tmp/*
