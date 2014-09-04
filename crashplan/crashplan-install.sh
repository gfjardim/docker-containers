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
wget -nv http://download.code42.com/installs/linux/install/CrashPlan/CrashPlan_3.6.3_Linux.tgz -O - | tar -zx -C /tmp

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

# Remove install data
rm -rf ${INSTALL_DIR}
