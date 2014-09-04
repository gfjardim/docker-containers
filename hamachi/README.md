docker-hamachi
==============

LogMeIn Hamachi: 
https://secure.logmein.com/products/hamachi/

This is a docker container to LogMeNn Hamachi. To run:

```
docker run -d --name="Hamachi" --net="host" --privileged="true" -e ACCOUNT="your@email.com" -v "/mnt/cache/appdata/Hamachi/":"/config":rw -v "/etc/localtime":"/etc/localtime":ro gfjardim/hamachi
```
