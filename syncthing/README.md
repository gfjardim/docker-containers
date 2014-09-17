# Syncthing

Docker image for Syncthing (http://syncthing.net)

Run with:

```
docker run -d --name="Syncthing" \
      --net="bridge" \
      -p 8080:8080/tcp \
      -p 22000:22000/tcp \
      -p 21025:21025/udp \
      -v "/mnt/user/appdata/syncthing":"/config":rw gfjardim/syncthing
```

