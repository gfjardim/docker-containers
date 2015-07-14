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
# Install excludes
cat <<'EOT' >/etc/dpkg/dpkg.cfg.d/excludes
path-exclude /usr/share/doc/*
# we need to keep copyright files for legal reasons
path-include /usr/share/doc/*/copyright
path-exclude /usr/share/man/*
path-exclude /usr/share/groff/*
path-exclude /usr/share/info/*
# lintian stuff is small, but really unnecessary
path-exclude /usr/share/lintian/*
path-exclude /usr/share/linda/*
# Drop locales except English
path-exclude=/usr/share/locale/*
path-include=/usr/share/locale/en/*
path-include=/usr/share/locale/locale.alias
EOT

# Repositories
add-apt-repository "deb http://us.archive.ubuntu.com/ubuntu/ trusty universe multiverse"
add-apt-repository "deb http://us.archive.ubuntu.com/ubuntu/ trusty-updates universe multiverse"
apt-add-repository ppa:ubuntu-mate-dev/ppa
apt-add-repository ppa:ubuntu-mate-dev/trusty-mate

# Use mirrors
# sed -i -e "s#http://[^\s]*archive.ubuntu[^\s]* #mirror://mirrors.ubuntu.com/mirrors.txt #g" /etc/apt/sources.list

# Install Dependencies
apt-get update -qq
apt-get install -y --force-yes --no-install-recommends \
    xdg-utils \
    python \
    wget \
    openjdk-7-jre \
    supervisor \
    sudo \
    nano \
    net-tools \
    mate-desktop-environment-core \
    x11vnc \
    xvfb \
    gtk2-engines-murrine \
    ttf-ubuntu-font-family 

apt-get install -y --force-yes xrdp

#########################################
##  FILES, SERVICES AND CONFIGURATION  ##
#########################################

#config
cat <<'EOT' > /etc/my_init.d/config.sh
#!/bin/bash
if [[ $(cat /etc/timezone) != $TZ ]] ; then
  echo "$TZ" > /etc/timezone
  dpkg-reconfigure -f noninteractive tzdata
fi

mkdir -p /home/ubuntu/unraid /var/run/sshd /root/.vnc /config/id

if [ -d "/home/ubuntu/unraid/wallpapers" ]; then
  echo "using existing wallpapers etc..."
else
  mkdir -p /home/ubuntu/unraid/wallpapers
  cp /root/wallpapers/* /home/ubuntu/unraid/wallpapers/
fi
/usr/bin/supervisord -c /opt/supervisord.conf 
while [ 1 ]; do
  bash
done

EOT

cat <<'EOT' > /opt/supervisord.conf
[supervisord]
nodaemon=false

[program:xvfb]
priority=10
directory=/
command=/usr/bin/Xvfb :1 -screen 0 1700x950x16
user=root
autostart=true
autorestart=true
stopsignal=QUIT
stdout_logfile=/var/log/xvfb.log
stderr_logfile=/var/log/xvfb.err

[program:matesession]
priority=15
directory=/home/ubuntu
command=/usr/bin/mate-session
user=ubuntu
autostart=true
autorestart=true
stopsignal=QUIT
environment=DISPLAY=":1",HOME="/home/ubuntu"
stdout_logfile=/var/log/lxsession.log
stderr_logfile=/var/log/lxsession.err

[program:x11vnc]
priority=20
directory=/
command=x11vnc -display :1 -xkb
#command=x11vnc -display :1 -listen localhost -xkb
user=root
autostart=true
autorestart=true
stopsignal=QUIT
stdout_logfile=/var/log/x11vnc.log
stderr_logfile=/var/log/x11vnc.err

[program:xrdp]
priority=30
command=/usr/sbin/xrdp -nodaemon
process_name = xrdp
user=root
stdout_logfile=/var/log/xrdp.log
stderr_logfile=/var/log/xrdp.err

[program:xrdp-sesman]
priority=35
command=/usr/sbin/xrdp-sesman --nodaemon
process_name = xrdp-sesman
user=root
stdout_logfile=/var/log/xrdp-sesman.log
stderr_logfile=/var/log/xrdp-sesman.err

[program:xrdp]
priority=30
command=/etc/init.d/xrdp start
process_name = xrdp
user=root
EOT

cat <<'EOT' > /etc/xrdp/xrdp.ini
[globals]
bitmap_cache=yes
bitmap_compression=yes
port=3389
crypt_level=low
channel_code=1
max_bpp=24
#black=000000
#grey=d6d3ce
#dark_grey=808080
#blue=08246b
#dark_blue=08246b
#white=ffffff
#red=ff0000
#green=00ff00
#background=626c72

[xrdp1]
name=sesman-Xvnc
lib=libvnc.so
username=ask
password=ask
ip=127.0.0.1
port=-1

[xrdp2]
name=reconnect-SESS1
lib=libvnc.so
username=ubuntu
password=PASSWD
ip=127.0.0.1
port=5910

[xrdp3]
name=reconnect-SESS2
lib=libvnc.so
username=ubuntu
password=PASSWD
ip=127.0.0.1
port=5911

[xrdp4]
name=reconnect-SESS3
lib=libvnc.so
username=ubuntu
password=PASSWD
ip=127.0.0.1
port=5912

[xrdp4]
name=reconnect-SESS4
lib=libvnc.so
username=ubuntu
password=PASSWD
ip=127.0.0.1
port=5913
EOT

chmod -R +x /etc/service/ /etc/my_init.d/

#########################################
##             INSTALLATION            ##
#########################################

cat <<'EOT' > /opt/install-crashplan.sh
#!/bin/bash
APP_BASENAME=CrashPlan
DIR_BASENAME=crashplan
TARGETDIR=/usr/local/crashplan
BINSDIR=/usr/local/bin
MANIFESTDIR=/data
INITDIR=/etc/init.d
RUNLEVEL=`who -r | sed -e 's/^.*\(run-level [0-9]\).*$/\1/' | cut -d \  -f 2`
RUNLVLDIR=/etc/rc${RUNLEVEL}.d
JAVACOMMON=`which java`

# Downloading Crashplan
wget -nv https://download.code42.com/installs/linux/install/CrashPlan/CrashPlan_4.3.0_Linux.tgz -O - | tar -zx -C /tmp

# Installation directory
cd /tmp/CrashPlan-install
INSTALL_DIR=`pwd`

# Make the destination dir
mkdir -p ${TARGETDIR}

# create a file that has our install vars so we can later uninstall
echo "" > ${TARGETDIR}/install.vars
echo "TARGETDIR=${TARGETDIR}" >> ${TARGETDIR}/install.vars
echo "BINSDIR=${BINSDIR}" >> ${TARGETDIR}/install.vars
echo "MANIFESTDIR=${MANIFESTDIR}" >> ${TARGETDIR}/install.vars
echo "INITDIR=${INITDIR}" >> ${TARGETDIR}/install.vars
echo "RUNLVLDIR=${RUNLVLDIR}" >> ${TARGETDIR}/install.vars
NOW=`date +%Y%m%d`
echo "INSTALLDATE=$NOW" >> ${TARGETDIR}/install.vars
cat ${INSTALL_DIR}/install.defaults >> ${TARGETDIR}/install.vars
echo "JAVACOMMON=${JAVACOMMON}" >> ${TARGETDIR}/install.vars

# Definition of ARCHIVE occurred above when we extracted the JAR we need to evaluate Java environment
ARCHIVE=`ls ./*_*.cpi`
cd ${TARGETDIR}
cat "${INSTALL_DIR}/${ARCHIVE}" | gzip -d -c - | cpio -i --no-preserve-owner
cd ${INSTALL_DIR}

#update the configs for file storage

if grep "<manifestPath>.*</manifestPath>" ${TARGETDIR}/conf/default.service.xml > /dev/null
        then
                sed -i "s|<manifestPath>.*</manifestPath>|<manifestPath>${MANIFESTDIR}</manifestPath>|g" ${TARGETDIR}/conf/default.service.xml
        else
                sed -i "s|<backupConfig>|<backupConfig>\n\t\t\t<manifestPath>${MANIFESTDIR}</manifestPath>|g" ${TARGETDIR}/conf/default.service.xml
fi

sed -i "s|</servicePeerConfig>|</servicePeerConfig>\n\t<serviceUIConfig>\n\t\t\
       <serviceHost>0.0.0.0</serviceHost>\n\t\t<servicePort>4243</servicePort>\n\t\t\
       <connectCheck>0</connectCheck>\n\t\t<showFullFilePath>false</showFullFilePath>\n\t\
       </serviceUIConfig>|g" ${TARGETDIR}/conf/default.service.xml

# the log dir
LOGDIR=${TARGETDIR}/log
chmod 777 $LOGDIR

# Install the control script for the service
cp scripts/run.conf ${TARGETDIR}/bin

# Add desktop shortcut
cp scripts/CrashPlanDesktop  ${TARGETDIR}/bin/
cat <<'EOS' > /usr/share/applications/CrashPlan.desktop
[Desktop Entry]
Version=1.0
Encoding=UTF-8
Name=CrashPlan
Categories=Utilities;
Comment=CrashPlan Desktop
Comment[en_CA]=CrashPlan Desktop
Exec=/usr/local/crashplan/bin/CrashPlanDesktop
Icon=/usr/local/crashplan/skin/icon_app_128x128.png
Hidden=false
Terminal=false
Type=Application
GenericName[en_CA]=
EOS

# Tweak the ui.properties to docker environment
sed -i -e "s|.*serviceHost.*|serviceHost=172.17.42.1|" ${TARGETDIR}/conf/ui.properties

# Create lib symlink
ln -sf /config/id /var/lib/crashplan

# Fix permissions
chmod -R u-x,go-rwx,go+u,ugo+X /usr/local/crashplan
chmod -R 777 /usr/local/crashplan/bin

# Remove install data
rm -rf ${INSTALL_DIR}

mkdir -p /home/ubuntu/.config/autostart/ /home/ubuntu/Desktop/
cp /usr/share/applications/CrashPlan.desktop /home/ubuntu/.config/autostart/CrashPlan.desktop
cp /usr/share/applications/CrashPlan.desktop /home/ubuntu/Desktop/CrashPlan.desktop
chmod +x /home/ubuntu/.config/autostart/CrashPlan.desktop /home/ubuntu/Desktop/CrashPlan.desktop
chown -R ubuntu:ubuntu /usr/local/crashplan /home/ubuntu/Desktop /home/ubuntu/.config

EOT

# create ubuntu user
useradd --create-home --shell /bin/bash --user-group --groups adm,sudo ubuntu
echo "ubuntu:PASSWD" | chpasswd
usermod -u 99 ubuntu
usermod -g 100 ubuntu
bash /opt/install-crashplan.sh

#########################################
##                 CLEANUP             ##
#########################################

# Clean APT install files
apt-get clean -y
rm -rf /var/lib/apt/lists/* /var/cache/* /var/tmp/* /usr/share/man /usr/share/groff /usr/share/info /usr/share/lintian /usr/share/linda /var/cache/man
find /usr/share/doc -depth -type f ! -name copyright|xargs rm 
find /usr/share/doc -empty|xargs rmdir 
