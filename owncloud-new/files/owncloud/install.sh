#!/bin/bash

echo "Downloading ownCloud version ${OWNCLOUD_VERSION} ..."
curl -sL "https://download.owncloud.org/community/owncloud-${OWNCLOUD_VERSION}.tar.bz2" -o /tmp/owncloud.tar.bz2
sum1=$(md5sum /tmp/owncloud.tar.bz2)
sum2=$(curl -sL https://download.owncloud.org/community/owncloud-${OWNCLOUD_VERSION}.tar.bz2.md5)
if [ "${sum1:0:32}" == "${sum2:0:32}" ]; then
  echo "File integrity checked, installing..."
  mkdir var/www
  tar -jxf /tmp/owncloud.tar.bz2 -C /var/www  
else
  echo "Downloaded file corrupted, aborting..."
  exit 1
fi