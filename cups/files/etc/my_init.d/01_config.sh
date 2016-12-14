#!/bin/bash

mkdir -p /config/cups /config/spool /config/logs /config/cache /config/cups/ssl /config/cups/ppd /config/cloudprint

# Copy missing config files
cd /etc/cups
for f in *.conf ; do 
  if [ ! -f "/config/cups/${f}" ]; then
    cp ./${f} /config/cups/
  fi
done