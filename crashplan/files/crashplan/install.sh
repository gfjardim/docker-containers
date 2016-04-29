#!/bin/bash

# Install Crashplan
APP_BASENAME=CrashPlan
DIR_BASENAME=crashplan
TEMPDIR=/tmp/crashplan-install
TARGETDIR=/usr/local/crashplan
BINSDIR=/usr/local/bin
MANIFESTDIR=/backups
INITDIR=/etc/init.d
RUNLEVEL=$(who -r | sed -e 's/^.*\(run-level [0-9]\).*$/\1/' | cut -d \  -f 2)
RUNLVLDIR=/etc/rc${RUNLEVEL}.d
JAVACOMMON=$(which java)

# Downloading Crashplan
wget -nv http://download.code42.com/installs/linux/install/CrashPlan/CrashPlan_${CP_VERSION}_Linux.tgz -O - | tar -zx -C /tmp

# Make the destination dirs
mkdir -p ${TARGETDIR}
mkdir -p /var/lib/crashplan

# create a file that has our install vars so we can later uninstall
echo "" > ${TARGETDIR}/install.vars
echo "TARGETDIR=${TARGETDIR}" >> ${TARGETDIR}/install.vars
echo "BINSDIR=${BINSDIR}" >> ${TARGETDIR}/install.vars
echo "MANIFESTDIR=${MANIFESTDIR}" >> ${TARGETDIR}/install.vars
echo "INITDIR=${INITDIR}" >> ${TARGETDIR}/install.vars
echo "RUNLVLDIR=${RUNLVLDIR}" >> ${TARGETDIR}/install.vars
echo "INSTALLDATE=$(date +%Y%m%d)" >> ${TARGETDIR}/install.vars
cat ${TEMPDIR}/install.defaults >> ${TARGETDIR}/install.vars
echo "JAVACOMMON=${JAVACOMMON}" >> ${TARGETDIR}/install.vars

# Extract CrashPlan installer files
cd ${TARGETDIR}
cat $(ls ${TEMPDIR}/*_*.cpi) | gzip -d -c - | cpio -i --no-preserve-owner

# Update the configs for file storage
if grep "<manifestPath>.*</manifestPath>" ${TARGETDIR}/conf/default.service.xml > /dev/null; then
  sed -i "s|<manifestPath>.*</manifestPath>|<manifestPath>${MANIFESTDIR}</manifestPath>|g" ${TARGETDIR}/conf/default.service.xml
else
  sed -i "s|<backupConfig>|<backupConfig>\n\t\t\t<manifestPath>${MANIFESTDIR}</manifestPath>|g" ${TARGETDIR}/conf/default.service.xml
fi

# Remove the default backup set
if grep "<backupSets>.*</backupSets>" ${TARGETDIR}/conf/default.service.xml > /dev/null; then
    sed -i "s|<backupSets>.*</backupSets>|<backupSets></backupSets>|g" ${TARGETDIR}/conf/default.service.xml
fi

# Install the control script for the service
cp ${TEMPDIR}/scripts/run.conf ${TARGETDIR}/bin

# Add desktop startup script
cp ${TEMPDIR}/scripts/CrashPlanDesktop /startapp.sh
sed -i 's|"\$SCRIPTDIR/.."|\$(dirname $SCRIPTDIR)|g' /startapp.sh

# Fix permissions
chmod -R u-x,go-rwx,go+u,ugo+X ${TARGETDIR}
chown -R nobody ${TARGETDIR} /var/lib/crashplan

# Add service to init
cat <<'EOT' > /etc/init.d/crashplan
#!/bin/bash
case "$1" in
  start)
    /usr/bin/sv start crashplan
    /usr/bin/sv start openbox

    ;;
  stop)
    /usr/bin/sv stop crashplan
    /usr/bin/sv stop openbox
    ;;
  restart)
    /usr/bin/sv restart crashplan
    /usr/bin/sv restart openbox
    ;;
esac
EOT
chmod +x /etc/init.d/crashplan