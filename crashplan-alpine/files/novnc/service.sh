#!/usr/bin/with-contenv bash

exec s6-setuidgid root /opt/novnc/utils/launch.sh --listen WEB_PORT --vnc localhost:VNC_PORT