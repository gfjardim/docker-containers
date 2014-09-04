#!/bin/bash
umask 000

cd /opt/MediaBrowser
exec /sbin/setuser nobody mono /opt/MediaBrowser/MediaBrowser.Server.Mono.exe
