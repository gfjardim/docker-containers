#!/bin/bash
umask 000

# Madsonic configuration
HOME_FOLDER=/config

# move transcode to config directory
if [[ -d /opt/transcode ]]; then
  cp -rf /opt/transcode /config/
  rm -rf /opt/transcode
fi

# Set https port if SSL = 1
[[ ${SSL} == 1 ]] && HTTPS_PORT=4050 || HTTPS_PORT=0

# Create Madsonic home directory.
mkdir -p ${HOME_FOLDER}/incoming \
         ${HOME_FOLDER}/podcast \
         ${HOME_FOLDER}/playlists/import \
         ${HOME_FOLDER}/playlists/export \
         ${HOME_FOLDER}/playlists/backup 

exec /sbin/setuser nobody /opt/madsonic/madsonic.sh --home=${HOME_FOLDER} \
                                                    --host=0.0.0.0 \
                                                    --port=4040 \
                                                    --https-port=${HTTPS_PORT} \
                                                    --default-music-folder=/media \
                                                    --default-upload-folder=${HOME_FOLDER}/incoming \
                                                    --default-podcast-folder=${HOME_FOLDER}/podcast \
                                                    --default-playlist-import-folder=${HOME_FOLDER}/playlists/import \
                                                    --default-playlist-export-folder=${HOME_FOLDER}/playlists/export \
                                                    --default-playlist-backup-folder=${HOME_FOLDER}/playlists/backup \
                                                    --timezone=${TZ}