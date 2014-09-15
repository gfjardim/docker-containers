#!/bin/bash
umask 000
STGUIADDRESS="https://0.0.0.0:8080" 

chown -R nobody:users /opt/syncthing

exec /sbin/setuser nobody /opt/syncthing/syncthing -home="/config"