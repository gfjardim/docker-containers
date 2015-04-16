docker-owncloud
===============

Docker container for ownCloud: http://owncloud.com

    /usr/bin/docker run -d --name="ownCloud" --net="bridge" -e SUBJECT="/C=COUTRY/ST=STATE/L=CITY/O=ORGANIZATION/OU=UNIT/CN=myhome.com" -p 8000:8000/tcp -v "/path/to/your/owncloud/data":"/var/www/owncloud/data":rw -v "/etc/localtime":"/etc/localtime":ro gfjardim/owncloud

Change the SUBJECT variable to reflect your scenario.

