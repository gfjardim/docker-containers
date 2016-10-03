#!/bin/bash

PID=$(ps aux | grep -i [C]rashPlanService | awk {'print $2'})

if [ -n "$PID" ]; then
  kill -9 $PID
fi