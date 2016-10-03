#!/bin/bash

# Repositories
echo "http://dl-cdn.alpinelinux.org/alpine/edge/testing"   >> /etc/apk/repositories
echo "http://dl-cdn.alpinelinux.org/alpine/edge/community" >> /etc/apk/repositories

apk update
apk add alpine-base \
        bash \
        curl \
        tzdata \
        shadow

#########################################
##        ENVIRONMENTAL CONFIG         ##
#########################################
# set version for s6 overlay
OVERLAY_VERSION="v1.18.1.5"
OVERLAY_URL="https://github.com/just-containers/s6-overlay/releases/download/${OVERLAY_VERSION}/s6-overlay-amd64.tar.gz"
# add overlay s6
curl -L "${OVERLAY_URL}" | tar zx -C /

groupmod -g 100 users
useradd -u 99 -U -d /config -s /bin/false abc
usermod -G users abc

cat <<'EOS' >> /etc/cont-init.d/10-config_user
#!/usr/bin/with-contenv bash

PUID=${PUID:-99}
PGID=${PGID:-100}

if [ ! "$(id -u abc)" -eq "$PUID" ]; then usermod -o -u "$PUID" abc ; fi
if [ ! "$(id -g abc)" -eq "$PGID" ]; then groupmod -o -g "$PGID" abc ; fi

chown abc:abc /app
chown abc:abc /config
chown abc:abc /defaults
EOS

# create some folders
mkdir -p /config /app /defaults

#########################################
##    REPOSITORIES AND DEPENDENCIES    ##
#########################################



apk add alpine-base \
        bash \
        tzdata \
        shadow \
        pwgen \
        xvfb \
        linux-pam \
        perl \
        openbox \
        xterm \
        python \
        ca-certificates \
        openssl \
        findutils \
        coreutils \
        procps

apk add --virtual=build-dependencies \
        curl \
        tar \
        wget \
        expect

apk add grep sed cpio gzip




# # add glibc
# curl -L https://raw.githubusercontent.com/sgerrand/alpine-pkg-glibc/master/sgerrand.rsa.pub \
#      -o /etc/apk/keys/sgerrand.rsa.pub

# curl -L https://github.com/sgerrand/alpine-pkg-glibc/releases/download/2.23-r3/glibc-2.23-r3.apk \
#      -o /tmp/glibc-2.23-r3.apk  && \
#      apk add /tmp/glibc-2.23-r3.apk && \
#      rm /tmp/glibc-2.23-r3.apk

# curl -L https://github.com/sgerrand/alpine-pkg-glibc/releases/download/unreleased/glibc-bin-2.23-r3.apk \
#      -o /tmp/glibc-bin-2.23-r3.apk && \
#      apk add /tmp/glibc-bin-2.23-r3.apk && \
#      rm /tmp/glibc-bin-2.23-r3.apk

# curl -L https://github.com/sgerrand/alpine-pkg-glibc/releases/download/unreleased/glibc-i18n-2.23-r3.apk \
#      -o /tmp/glibc-i18n-2.23-r3.apk && \
#      apk add /tmp/glibc-i18n-2.23-r3.apk && \
#      rm /tmp/glibc-i18n-2.23-r3.apk && \

# /usr/glibc-compat/bin/localedef --force --inputfile POSIX --charmap UTF-8 C.UTF-8 || true && \

# echo "export LANG=C.UTF-8" > /etc/profile.d/locale.sh && \

# apk del glibc-i18n

#########################################
##  FILES, SERVICES AND CONFIGURATION  ##
#########################################

# # CrashPlan Service
# mkdir -p /etc/service/crashplan /etc/service/crashplan/control
# cp /files/crashplan/service.sh /etc/service/crashplan/run
# cp /files/crashplan/service_stop.sh /etc/service/crashplan/control/t

# # CrashPlan Desktop
# cp /files/crashplan/desktop.sh /opt/startapp.sh
# cp /files/crashplan/desktop_stop.sh /opt/stopapp.sh
# chmod +x /opt/startapp.sh /opt/stopapp.sh

# noVNC Service
mkdir -p /opt/novnc \
         /opt/novnc/utils/websockify \
         /etc/services.d/novnc && \

cp /files/novnc/service.sh /etc/services.d/novnc/run && \
curl -L https://github.com/kanaka/noVNC/archive/master.tar.gz | tar -xz --strip=1 -C /opt/novnc && \
sed -i -- "s/ps -p/ps -o pid | grep/g" /opt/novnc/utils/launch.sh && \
curl -L https://github.com/kanaka/websockify/archive/master.tar.gz | tar -xz --strip=1 -C /opt/novnc/utils/websockify

# Openbox Service
mkdir -p /etc/services.d/openbox && \
cp /files/openbox/service.sh /etc/services.d/openbox/run


# TigerVNC Service
mkdir -p /etc/services.d/tigervnc /opt/vncpasswd
cp /files/tigervnc/service.sh /etc/services.d/tigervnc/run
curl -L https://bintray.com/tigervnc/stable/download_file?file_path=tigervnc-1.7.0.x86_64.tar.gz | tar -xz --strip=1 -C /
curl -L https://github.com/trinitronx/vncpasswd.py/archive/master.tar.gz | tar -zx --strip=1 -C /opt/vncpasswd

# # Config File
mkdir -p /etc/cont-init.d/
cp /files/config.sh /etc/cont-init.d/30-config
# cp /files/01_config.sh /etc/my_init.d/01_config.sh

# chmod -R +x /etc/service/ /etc/my_init.d/

#########################################
##             INSTALLATION            ##
#########################################

# # Install Crashplan
# /bin/bash /files/crashplan/install.sh

# Install TigerVNC
# /bin/bash /files/tigervnc/install.sh

# Install noVNC

#########################################
##                 CLEANUP             ##
#########################################

# apk del --purge build-dependencies
rm -rf /var/cache/apk/* /tmp/*
