# Cloud-TP3


# Docker

* Remplir le fichier .env.prod

```shell
set -a; . .env.prod; set +a; docker stack deploy -c stack-nextcloud.yml nextcloud
```
