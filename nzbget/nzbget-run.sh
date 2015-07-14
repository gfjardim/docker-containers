#!/bin/bash
umask 000
if [[ -z $(pgrep nzbget) ]]; then /sbin/setuser nobody /opt/nzbget/nzbget -c /config/nzbget.conf -D; fi
while [ $(pgrep nzbget) ]; do sleep 1; done