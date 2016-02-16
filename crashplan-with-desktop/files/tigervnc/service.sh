#!/bin/bash
exec 2>&1

exec /sbin/setuser nobody /usr/bin/Xvnc :1 \
           -depth 24 \
           -rfbwait 30000 \
           SECURITY \
           -rfbport $((WEB_PORT-1)) \
           -bs \
           -ac \
           -pn \
           -fp /usr/share/fonts/X11/misc/,/usr/share/fonts/X11/75dpi/,/usr/share/fonts/X11/100dpi/ \
           -dpi 96 \
           -localhost \
           -desktop CrashPlan