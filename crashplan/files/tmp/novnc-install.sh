#!/bin/bash

# Install noVNC
mkdir /opt/novnc
curl -L https://github.com/kanaka/noVNC/archive/master.tar.gz | tar -xz --strip=1 -C /opt/novnc

mkdir -p /opt/novnc/utils/websockify
curl -L https://github.com/kanaka/websockify/archive/master.tar.gz | tar -xz --strip=1 -C /opt/novnc/utils/websockify