#!/bin/bash
umask 000

chown -R nobody:users /opt/syncthing /config/config /config/files

exec /sbin/setuser nobody /opt/syncthing/syncthing -home="/config" -gui-address="https://0.0.0.0:8080" 
