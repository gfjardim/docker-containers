#!/bin/bash
umask 000

exec /sbin/setuser nobody nzbget -D -c /config/nzbget.conf
