#!/bin/bash
exec 2>&1

WD=${WIDTH:-1280}
HT=${HEIGHT:-720}

exec /sbin/setuser nobody Xvnc4 :1 -geometry ${WD}x${HT} -depth 16 -rfbwait 30000 -SecurityTypes None -rfbport $((VNC_PORT-1)) -bs -ac \
           -pn -fp /usr/share/fonts/X11/misc/,/usr/share/fonts/X11/75dpi/,/usr/share/fonts/X11/100dpi/ \
           -co /etc/X11/rgb -dpi 96 -desktop CrashPlan