#!/bin/bash
NZBUP_BRANCH=${NZBUP_BRANCH:-STABLE}

URL="https://raw.githubusercontent.com/${GIT_USER}/nzbget-updates/master"

echo "Installing ${NZBUP_BRANCH}"

echo "Downloading new version..."
wget -q --no-check-certificate "${URL}/nzbget-${NZBUP_BRANCH}-amd64.deb" -O /tmp/nzbget-update.deb
if [[ $? -ne 0 ]]; then
	echo "[ERROR] Download failed"
	exit 1
else
	echo "Downloading new version...OK";
fi

echo "Downloading libpar2-1..."
wget -q --no-check-certificate "${URL}/libpar2-1_0.4-3patched_amd64.deb" -O /tmp/libpar2-1_0.4-3patched_amd64.deb
if [[ $? -ne 0 ]]; then
	echo "[ERROR] Download failed"
	exit 1
else
	echo "Downloading libpar2-1...OK";
fi

# Backing up downloaded files
rm -rf /config/last_version
mkdir -p /config/last_version
cp /tmp/nzbget-update.deb /tmp/libpar2-1_0.4-3patched_amd64.deb /config/last_version/

echo "Restarting NzbGet..."

# Write the update.sh script 
cat > /tmp/update.sh << EOL
# Disabling the my_init service
chmod -x /etc/service/nzbget/run

# Killing nzbget
kill -15 \$(pgrep nzbget)

# Make a backup
regex=".*?:.?(.*?)"
if [[ \$(nzbget -v) =~ \$regex ]]; then
        VERSION=\${BASH_REMATCH[1]}
fi
bkp="/config/backup/nzbget-\$VERSION-$(date +'%m-%d-%Y').conf"
mkdir -p /config/backup
cp /config/nzbget.conf \$bkp 

# Installing the update
dpkg -P nzbget
dpkg -i /tmp/nzbget-update.deb
rm -f /tmp/nzbget-update.deb

# Update libpar2-1
dpkg -P libpar2-1
dpkg -i /tmp/libpar2-1_0.4-3patched_amd64.deb
rm -f /tmp/libpar2-1_0.4-3patched_amd64.deb

# Run firstrun.sh
/etc/my_init.d/firstrun.sh

# Enabling the my_init service
chmod +x /etc/service/nzbget/run
EOL