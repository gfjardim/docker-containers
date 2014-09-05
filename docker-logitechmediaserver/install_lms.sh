#!/bin/bash

OUT=$(wget -qO - http://downloads.slimdevices.com/nightly/index.php?ver=7.8)

# Try to catch the link or die
REGEX=".*href=\".(.*).deb\""
if [[ ${OUT} =~ ${REGEX} ]]; then
  URL="http://downloads.slimdevices.com/nightly${BASH_REMATCH[1]}.deb"
else
  exit 1
fi

wget -O /tmp/lms.deb $URL
