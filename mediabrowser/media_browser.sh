#!/bin/bash
umask 000

# Fix the timezone
if [[ $(cat /etc/timezone) != $TZ ]] ; then
  echo "$TZ" > /etc/timezone
  dpkg-reconfigure -f noninteractive tzdata
fi

chown -R nobody:users /opt/mediabrowser/
cd /opt/mediabrowser/

exec /sbin/setuser nobody mono /opt/mediabrowser/MediaBrowser.Server.Mono.exe \
                                -programdata /config \
                                -ffmpeg $(which ffmpeg) \
                                -ffprobe $(which ffprobe)
