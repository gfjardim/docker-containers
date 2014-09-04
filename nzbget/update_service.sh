#!/bin/bash

while sleep 5; do
	if [[ -f /tmp/update.sh ]]; then
		echo "Update found, updating."
		/bin/bash /tmp/update.sh
		rm /tmp/update.sh
	fi
done
