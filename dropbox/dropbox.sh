#!/bin/bash
umask 000
chown -R nobody:users /home
chmod -R u-x,go-rwx,go+u,ugo+X /home

exec /sbin/setuser nobody /opt/dropbox/dropboxd
