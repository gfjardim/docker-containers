#!/bin/bash

/opt/novnc/utils/launch.sh --listen VNC_PORT --vnc localhost:$((VNC_PORT-1))