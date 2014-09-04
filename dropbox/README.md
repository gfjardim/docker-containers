docker-dropbox
================

This is a Dockerfile setup for Dropbox - https://www.dropbox.com

To run:

docker run -d --name="dropbox" --privileged=true --net="host" -v /path/to/your/config:/home/.dropbox -v /path/to/your/files:/home/Dropbox -v /etc/localtime:/etc/localtime:ro gfjardim/dropbox

Old users: please change /config to /home/.dropbox and /dropbox to /home/Dropbox