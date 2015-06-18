#!/bin/bash

mkdir -p /config/cups /config/spool /config/logs /config/cache /config/cups/ssl /config/cloudprint

cd /etc/cups
for f in *.conf ; do 
  if [ ! -f "/config/cups/${f}" ]; then
    cp ./${f} /config/cups/
  fi
done

if [ ! -f "/config/cloudprint/Service State" ]; then
  /config/cloudprint
  python /opt/generate_cloudprint_config.py
fi
