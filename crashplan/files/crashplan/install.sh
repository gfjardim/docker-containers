#!/bin/bash

# Install Crashplan
TARGETDIR=/usr/local/crashplan
BINSDIR="${TARGETDIR}/bin"
CACHEDIR=/config/cache
MANIFESTDIR=/backup
INITDIR=/etc/init.d
RUNLVLDIR=/etc/rc2.d

# Downloading Crashplan
mkdir /tmp/crashplan
curl -L http://download.code42.com/installs/linux/install/CrashPlan/CrashPlan_${CP_VERSION}_Linux.tgz | tar -xz --strip=1 -C /tmp/crashplan
# curl -L http://192.168.0.100:88/CrashPlan_${CP_VERSION}_Linux.tgz | tar -xz --strip=1 -C /tmp/crashplan

cd /tmp/crashplan

# Adding some defaults
echo "TARGETDIR=${TARGETDIR}"     >> install.defaults
echo "BINSDIR=${BINSDIR}"         >> install.defaults
echo "MANIFESTDIR=${MANIFESTDIR}" >> install.defaults
echo "INITDIR=${INITDIR}"         >> install.defaults
echo "RUNLVLDIR=${RUNLVLDIR}"     >> install.defaults
# echo "JRE_X64_DOWNLOAD_URL=http://192.168.0.100:88/jre-linux-x64-1.8.0_72.tgz" >> install.defaults

# Creating directories
mkdir -p /usr/local/crashplan/bin /backup

# Skipping inverview
sed -i 's/INTERVIEW=0/INTERVIEW=1/g' install.sh

# Install
yes "" | /tmp/crashplan/install.sh

# Update the configs cache storage
if grep "<cachePath>.*</cachePath>" ${TARGETDIR}/conf/default.service.xml > /dev/null; then
  sed -i "s|<cachePath>.*</cachePath>|<cachePath>${CACHEDIR}</cachePath>|g" ${TARGETDIR}/conf/default.service.xml
else
  sed -i "s|<backupConfig>|<backupConfig>\n\t\t\t<cachePath>${CACHEDIR}</cachePath>|g" ${TARGETDIR}/conf/default.service.xml
fi

# Add service to init
cat <<'EOT' > ${INITDIR}/crashplan
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