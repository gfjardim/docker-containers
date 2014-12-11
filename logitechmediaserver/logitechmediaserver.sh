#!/bin/bash
chown -R nobody:users /config

squeezeboxserver --user nobody  --prefsdir /config/prefs --logdir /config/logs --cachedir /config/cache

