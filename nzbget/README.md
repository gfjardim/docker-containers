This is a Dockerfile setup for nzbget - http://nzbget.net/

To run:

```
docker run -d --name="nzbget" -v /path/to/dir/with/nzbget.conf:/config -v /path/to/downloads:/downloads -v /etc/localtime:/etc/localtime:ro -p 6789:6789 gfjardim/nzbget
```

If using nzbget for the first time the sample nzbget.conf will be utilized and the /downloads/nzbget directory will be created. The default username is nzbget and the default password is tegbzn6789

