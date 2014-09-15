#!/bin/bash
umask 000

[[ ! -f /config/btsync.conf ]] && cp /tmp/btsync.conf /config/
[[ ! -d /config/.sync ]] && mkdir -p /config/.sync

chown -R nobody:users /opt/btsync /config

exec /sbin/setuser nobody /opt/btsync/btsync --nodaemon --config "/config/btsync.conf"
