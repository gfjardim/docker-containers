#!/bin/bash

xsetroot -solid black -cursor_name left_ptr
if [ -e /opt/startapp.sh ]; then
  /opt/startapp.sh &
fi