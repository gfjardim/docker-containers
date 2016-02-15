#!/bin/bash

xsetroot -solid black -cursor_name left_ptr
if [ -e /opt/crashplan-desktop.sh ]; then 
  echo "Starting CrashPlan Desktop..."
  exec /opt/crashplan-desktop.sh
fi