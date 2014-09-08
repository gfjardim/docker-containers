#!/bin/bash
umask 000
chown -R nobody:users /home

exec /sbin/setuser nobody /opt/dropbox/dropboxd
