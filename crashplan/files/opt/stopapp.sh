#!/bin/bash

PID=$(ps aux | grep -i [C]rashPlanDesktop | awk {'print $2'})

if [ -n "$PID" ]; then
  kill -9 $PID
fi