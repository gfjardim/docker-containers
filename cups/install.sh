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
curl -skL https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add -
curl -skL http://www.bchemnet.com/suldr/suldr.gpg | apt-key add -
add-apt-repository "deb http://dl.google.com/linux/chrome/deb/ stable main"
add-apt-repository "deb http://www.bchemnet.com/suldr/ debian extra"

# Use mirrors
sed -i -e "s#http://[^\s]*archive.ubuntu[^\s]* #mirror://mirrors.ubuntu.com/mirrors.txt #g" /etc/apt/sources.list

# Install Dependencies
apt-get update -qq
apt-get install -qy --force-yes cups cups-pdf whois hplip suld-driver-4.01.17 google-chrome-stable python-cups inotify-tools

# Add AirPrint config tool
curl -skL https://raw.github.com/tjfontaine/airprint-generate/master/airprint-generate.py /opt/airprint-generate.py -o /opt/airprint-generate.py
chmod +x /opt/airprint-generate.py

#########################################
##  FILES, SERVICES AND CONFIGURATION  ##
#########################################

# Add files
cp -f /tmp/*.conf /etc/cups/
cp -f /tmp/etc-pam.d-cups /etc/pam.d/cups
cp -f /tmp/generate_cloudprint_config.py /opt/generate_cloudprint_config.py
chmod +x /opt/generate_cloudprint_config.py
mkdir -p /etc/cups/ssl

# Add services
# Add firstrun.sh to execute during container startup
mkdir -p /etc/my_init.d
cat <<'EOT' >/etc/my_init.d/config.sh
#!/bin/bash

mkdir -p /config/cups /config/spool /config/logs /config/cache /config/cups/ssl /config/cups/ppd /config/cloudprint

# Copy missing config files
cd /etc/cups
for f in *.conf ; do 
  if [ ! -f "/config/cups/${f}" ]; then
    cp ./${f} /config/cups/
  fi
done

# CloudPrint
if [[ -n ${CLOUD_PRINT_EMAIL} ]]; then
  # Create auth token
  if [[ $(grep -c 'auth_token' '/config/cloudprint/Service State') -eq 0 ]]; then
    cd /config/cloudprint
    python /opt/generate_cloudprint_config.py
  fi
else
  # Disable CloudPrint
  rm -rf /etc/service/chrome
fi
EOT
chmod +x /etc/my_init.d/config.sh

# Add cups to runit
mkdir /etc/service/cups
cat <<'EOT' >/etc/service/cups/run
#!/bin/sh
if [ -n "$CUPS_USER_ADMIN" ]; then
  if [ $(grep -ci $CUPS_USER_ADMIN /etc/shadow) -eq 0 ]; then
    useradd $CUPS_USER_ADMIN --system -G root,lpadmin --no-create-home --password $(mkpasswd $CUPS_USER_PASSWORD)
  fi
fi
exec /usr/sbin/cupsd -f -c /config/cups/cupsd.conf
EOT
chmod +x /etc/service/cups/run

# Add Chrome/CloudPrint to runit
mkdir /etc/service/chrome
cat <<'EOT' >/etc/service/chrome/run
#!/bin/bash

# Fix a weird chrome error
if [ ! -f "/usr/lib/libudev.so.0" ]; then
  ln -s /lib/x86_64-linux-gnu/libudev.so.1.3.5 /usr/lib/libudev.so.0
fi

/opt/google/chrome/chrome --type=service --enable-cloud-print-proxy --no-service-autorun --noerrdialogs --user-data-dir=/config/cloudprint --enable-logging=stderr
EOT
chmod +x /etc/service/chrome/run

# Add AirPrint to runit
mkdir /etc/service/air_print
cat <<'EOT' > /etc/service/air_print/run
#!/bin/bash

while [[ $(curl -sk localhost:631 >/dev/null; echo $?) -ne 0 ]]; do
  sleep 1
done

/opt/airprint-generate.py -d /avahi

inotifywait -m /config/cups/ppd -e create -e moved_to -e close_write|
    while read path action file; do
        echo "Printer ${file} modified, reloading Avahi services."
        /opt/airprint-generate.py -d /avahi
    done
EOT

cat <<'EOT' > /etc/service/air_print/finish
#!/bin/bash
rm -rf /avahi/AirPrint*
EOT
chmod +x /etc/service/air_print/*

# Disbale some cups backend that are unusable within a container
mv /usr/lib/cups/backend/parallel /usr/lib/cups/backend-available/
mv /usr/lib/cups/backend/serial /usr/lib/cups/backend-available/

# Disable dbus for avahi
sed -i "s|#enable-dbus.*|enable-dbus=no|g" /etc/avahi/avahi-daemon.conf

#########################################
##                 CLEANUP             ##
#########################################

# Clean APT install files
apt-get clean -y
rm -rf /var/lib/apt/lists/* /var/cache/* /var/tmp/*
