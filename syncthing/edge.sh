#!/bin/bash

if [[ ${EDGE} == 1 ]]; then
  latest_release=$(curl -k -L https://github.com/syncthing/syncthing/releases/latest 2>/dev/null)
  regex="(/syncthing/syncthing/releases/download/[^\/]*/syncthing-linux-amd64[^\"]*)"

  if [[ $latest_release =~ $regex ]]; then
    URL="https://github.com"${BASH_REMATCH[1]}
    echo "Updating Syncthing"
    rm -rf /opt/syncthing
    echo "Downloading package from: ${URL}"
    mkdir -p /opt/syncthing && wget -nv -O - "${URL}" | tar -xzf - --strip-components=1 -C /opt/syncthing
  else
    exit 0
  fi
fi