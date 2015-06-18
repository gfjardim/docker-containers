#!/bin/bash

inotifywait -m /config/cups/ppd -e create -e moved_to -e close_write|
    while read path action file; do
        echo "Printer ${file} modified, reloading Avahi services."
        /opt/airprint-generate.py -d /etc/avahi/services
    done
