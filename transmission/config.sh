#!/bin/bash
CONFIG="/config"

if [[ ! -f $CONFIG/settings.json ]]; then
  cp /tmp/settings.json $CONFIG/
fi

if [[ -n ${USERNAME} ]]; then
  echo "The username is: ${USERNAME}"
  sed -i -e "s#\(.*\"rpc-username\":\).*#\1 \"${USERNAME}\",#g" $CONFIG/settings.json
fi

if [[ -n ${PASSWORD} ]]; then
  echo "The password is: ${PASSWORD}"
  sed -i -e "s#\(.*\"rpc-password\":\).*#\1 \"${PASSWORD}\",#g" $CONFIG/settings.json
fi
