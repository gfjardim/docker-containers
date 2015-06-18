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
  chmod -x /etc/service/chrome/run
fi