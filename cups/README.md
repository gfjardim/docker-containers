cups-in-docker
==============

cups 1.7.1 inside debian:sid

```bash
docker run -e CUPS_USER_ADMIN=admin -e CUPS_USER_PASSWORD=secr3t -p 6631:631/tcp ticosax/cups-in-docker
```
