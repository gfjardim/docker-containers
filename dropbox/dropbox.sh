#!/bin/bash
umask 000
chown -R nobody:users /home

exec /sbin/setuser nobody /home/.dropbox-dist/dropboxd
