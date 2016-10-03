#!/bin/bash

# Install Crashplan
TARGETDIR=/usr/local/crashplan
BINSDIR="/usr/local/bin"
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
echo "TARGETDIR=${TARGETDIR}"     >> /tmp/crashplan/install.vars
echo "BINSDIR=${BINSDIR}"         >> /tmp/crashplan/install.vars
echo "MANIFESTDIR=${MANIFESTDIR}" >> /tmp/crashplan/install.vars
echo "INITDIR=${INITDIR}"         >> /tmp/crashplan/install.vars
echo "RUNLVLDIR=${RUNLVLDIR}"     >> /tmp/crashplan/install.vars
# echo "JRE_X64_DOWNLOAD_URL=http://192.168.0.100:88/jre-linux-x64-1.8.0_72.tgz" >> install.vars

# Creating directories
mkdir -p /usr/local/crashplan/bin /backup

# Skipping inverview
sed -i -e '/INTERVIEW=0/a source \"${SCRIPT_DIR}/install.vars\"' \
       -e 's/INTERVIEW=0/INTERVIEW=1/g' /tmp/crashplan/install.sh

# Install
yes "" | /tmp/crashplan/install.sh

# Remove installation files
cd / && rm -rf /tmp/crashplan

# Add service to init
cat <<'EOT' > ${INITDIR}/crashplan
#!/bin/bash
source /opt/default-values.sh
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
  status)
    eval 'exec 6<>/dev/tcp/127.0.0.1/${SERVICE_PORT} && echo "running" || echo "stopped"' 2>/dev/null
    exec 6>&- # close output connection
    exec 6<&- # close input connection
    ;;
esac
EOT
chmod +x /etc/init.d/crashplan