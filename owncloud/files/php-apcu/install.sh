#!/bin/bash
curl -skL http://mirrors.kernel.org/ubuntu/pool/universe/p/php-apcu/php5-apcu_4.0.7-1build1~ubuntu14.04.1_amd64.deb -o /tmp/php5-apcu.deb
dpkg -i /tmp/php5-apcu.deb
rm /tmp/php5-apcu.deb

cat <<'EOT' > /etc/php5/mods-available/apcu.ini
extension=apcu.so
apc.enabled=1
apc.enable_cli=1
EOT