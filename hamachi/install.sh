#!/bin/bash

if [ ! -e /dev/net/tun ] ; then
        echo Creating TunTap ..
        mkdir -p /dev/net
        mknod /dev/net/tun c 10 200
        chmod 0666 /dev/net/tun
fi

