#!/bin/bash
umask 0000

TARGETDIR=/usr/local/crashplan
export SWT_GTK3=0

. ${TARGETDIR}/install.vars
. ${TARGETDIR}/bin/run.conf

cd ${TARGETDIR}

until /bin/nc -z 127.0.0.1 TCP_PORT_4242; do
  sleep 1
done

if [ "_${VERSION_5_UI}" == "_true" ]; then
  ${TARGETDIR}/electron/crashplan > /config/desktop_output.log 2> /config/desktop_error.log &
else
  ${JAVACOMMON} ${GUI_JAVA_OPTS} -classpath "./lib/com.backup42.desktop.jar:./lang:./skin" com.backup42.desktop.CPDesktop \
                > /config/desktop_output.log 2> /config/desktop_error.log &
fi