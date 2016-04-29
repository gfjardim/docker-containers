#!/bin/bash
umask 0000

TARGETDIR=/usr/local/crashplan
export SWT_GTK3=0

. ${TARGETDIR}/install.vars
. ${TARGETDIR}/bin/run.conf

cd ${TARGETDIR}

i=0
until /bin/nc -z 127.0.0.1 $(cat /var/lib/crashplan/.ui_info|cut -d',' -f1); do
  sleep 1
  let i+=1
  if [ $i -gt 10 ]; then
    break
  fi
done

${JAVACOMMON} ${GUI_JAVA_OPTS} -classpath "./lib/com.backup42.desktop.jar:./lang:./skin" com.backup42.desktop.CPDesktop \
              > /config/desktop_output.log 2> /config/desktop_error.log