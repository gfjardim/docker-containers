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
add-apt-repository ppa:webupd8team/java

# Accept JAVA license
echo "oracle-java7-installer shared/accepted-oracle-license-v1-1 select true" | sudo /usr/bin/debconf-set-selections

# Install Dependencies
apt-get update -qq
apt-get install -qy grep sed cpio gzip wget oracle-java7-installer

#########################################
##  FILES, SERVICES AND CONFIGURATION  ##
#########################################

mkdir -p /etc/my_init.d
cat <<'EOT' > /etc/my_init.d/config.sh
#!/bin/bash
_link() {
  if [[ -L ${2} && $(readlink ${2}) == ${1} ]]; then
    return 0
  fi
  if [[ ! -e ${1} ]]; then
    if [[ -d ${2} ]]; then
      mkdir -p "${1}"
      pushd ${2} &>/dev/null
      find . -type f -exec cp --parents '{}' "${1}/" \;
      popd &>/dev/null
    elif [[ -f ${2} ]]; then
      if [[ ! -d $(dirname ${1}) ]]; then
        mkdir -p $(dirname ${1})
      fi
      cp -f "${2}" "${1}"
    else
      mkdir -p "${1}"
    fi
  fi
  if [[ -d ${2} ]]; then
    rm -rf "${2}"
  elif [[ -f ${2} || -L ${2} ]]; then
    rm -f "${2}"
  fi
  if [[ ! -d $(dirname ${2}) ]]; then
    mkdir -p $(dirname ${2})
  fi
  ln -sf ${1} ${2}
}

# Fix the timezone
if [[ $(cat /etc/timezone) != $TZ ]] ; then
  echo "$TZ" > /etc/timezone
  dpkg-reconfigure -f noninteractive tzdata
fi

# move identity out of container, this prevent having to adopt account every time you rebuild the Docker
_link /config/id /var/lib/crashplan
# move cache directory out of container, this prevents re-synchronization every time you rebuild the Docker
_link /config/cache /usr/local/crashplan/cache
# move log directory out of container
_link /config/log /usr/local/crashplan/log
# move conf directory out of container
if [[ ! -f /config/conf/default.service.xml ]]; then
  rm -rf /config/conf
fi
_link /config/conf /usr/local/crashplan/conf
# move run.conf out of container
# adjust RAM as described here: http://support.code42.com/CrashPlan/Latest/Troubleshooting/CrashPlan_Runs_Out_Of_Memory_And_Crashes
if [[ ! -f /config/bin/run.conf ]]; then
  rm -rf /config/bin
fi
_link /config/bin /usr/local/crashplan/bin

echo "4243,unRAID" > /config/id/.ui_info

chown -R nobody:users /config
EOT

mkdir -p /etc/service/crashplan
cat <<'EOT' > /etc/service/crashplan/run
#!/bin/bash
umask 000
TARGETDIR=/usr/local/crashplan
if [[ -f $TARGETDIR/install.vars ]]; then
  . $TARGETDIR/install.vars
else
  echo "Did not find $TARGETDIR/install.vars file."
  exit 1
fi
if [[ -e $TARGETDIR/bin/run.conf ]]; then
  . $TARGETDIR/bin/run.conf
else
  echo "Did not find $TARGETDIR/bin/run.conf file."
  exit 1
fi
cd $TARGETDIR
FULL_CP="$TARGETDIR/lib/com.backup42.desktop.jar:$TARGETDIR/lang"
$JAVACOMMON $SRV_JAVA_OPTS -classpath $FULL_CP com.backup42.service.CPService > /config/engine_output.log 2> /config/engine_error.log
exit 0
EOT

cat <<'EOS' > /opt/crashplan-install.sh
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
cat <<'EOT' > /usr/share/applications/CrashPlan.desktop
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
EOT

# Tweak the ui.properties to docker environment
sed -i -e "s|.*serviceHost.*|serviceHost=172.17.42.1|" ${TARGETDIR}/conf/ui.properties
chmod -R 777 /usr/local/crashplan

# Disable auto update
chmod -R -x /usr/local/crashplan/upgrade/

# Fix permissions
chmod -R u-x,go-rwx,go+u,ugo+X /usr/local/crashplan
chmod -R 777 /usr/local/crashplan/bin

# Remove install data
rm -rf ${INSTALL_DIR}
EOS

chmod -R +x /etc/service/ /etc/my_init.d/

#########################################
##             INSTALLATION            ##
#########################################

# Install Crashplan
chmod +x /opt/crashplan-install.sh
/opt/crashplan-install.sh
mkdir -p /var/lib/crashplan
chown -R nobody /usr/local/crashplan /var/lib/crashplan

#########################################
##                 CLEANUP             ##
#########################################

# Clean APT install files
apt-get clean -y
rm -rf /var/lib/apt/lists/* /var/cache/* /var/tmp/*

