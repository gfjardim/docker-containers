#!/bin/bash

# Install TigerVNC
curl -L https://dl.bintray.com/tigervnc/stable/tigervnc-1.7.0.x86_64.tar.gz | tar -xz --strip=1 -C /

# vncpasswd.py
mkdir -p /opt/vncpasswd
curl -L https://github.com/trinitronx/vncpasswd.py/archive/master.tar.gz | tar -zx --strip=1 -C /opt/vncpasswd