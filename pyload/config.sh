#!/bin/bash

if [[ ! -e /config/pyload.conf ]]; then
	cp -rf /tmp/pyload-config/* /config/
fi
chown -R nobody:users /config