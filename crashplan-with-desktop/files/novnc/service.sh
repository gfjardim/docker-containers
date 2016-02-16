#!/bin/bash

/opt/novnc/utils/launch.sh --listen WEB_PORT --vnc localhost:$((WEB_PORT-1))