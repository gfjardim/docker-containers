docker-transmission
==============

This is a Dockerfile setup for Transmission - https://www.transmissionbt.com/

To run:

docker run -d --net="host" --name="Transmission" -e USERNAME="admin" -e PASSWORD="password" -v /path/to/config:/config -v /path/to/downloads:/downloads -v /etc/localtime:/etc/localtime:ro gfjardim/transmission
