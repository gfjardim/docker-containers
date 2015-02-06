docker-crashplan
================

This is a Dockerfile setup for CrashPlan - https://www.crashplan.com

To run:

docker run -d -h ${HOSTNAME} --name=crashplan -v /path/to/your/config:/config -v /mnt/user:/data -v /etc/localtime:/etc/localtime:ro -p 4242:4242 -p 4243:4243 gfjardim/crashplan
