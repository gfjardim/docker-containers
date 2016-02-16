#!/bin/bash

# Install TigerVNC
curl -L https://bintray.com/artifact/download/tigervnc/stable/tigervnc-Linux-x86_64-1.6.0.tar.gz | tar -zx -C /

# vncpasswd.py
mkdir -p /opt/vncpasswd
curl -L https://github.com/trinitronx/vncpasswd.py/archive/master.tar.gz | tar -zx --strip=1 -C /opt/vncpasswd