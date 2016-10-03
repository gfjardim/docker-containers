#!/bin/bash

# Openbox Autostart
if [ ! -d "/config/.config/openbox" ]; then

  mkdir -p /config/.config/openbox /config/.cache
  cp /files/openbox/autostart.sh /config/.config/openbox/autostart
  cp /files/openbox/rc.xml /config/.config/openbox/rc.xml
  chown -R abc:abc /config

fi

rm -f /tmp/.X1-lock
exec env DISPLAY=:1 HOME=/config exec s6-setuidgid abc /usr/bin/openbox-session