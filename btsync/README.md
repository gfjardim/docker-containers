# Bittorrent Sync

Docker container for Bittorrent Sync

Run with:

```
docker run -d --name="BTSync" \
        --net="bridge" \
        -p 8888:8888/tcp \
        -p 5555:5555/tcp \
        -p 3838:3838/udp \
        -v "/mnt/user/appdata/BTSync":"/config":rw \
        gfjardim/btsync
```

