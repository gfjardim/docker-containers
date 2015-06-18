#!/bin/bash

# Fix a weird chrome error
if [ ! -f "/usr/lib/libudev.so.0" ]; then
  ln -s /lib/x86_64-linux-gnu/libudev.so.1.3.5 /usr/lib/libudev.so.0
fi

/opt/google/chrome/chrome --type=service --enable-cloud-print-proxy --no-service-autorun --noerrdialogs --user-data-dir=/config/cloudprint --enable-logging=stderr
