# ColdFusion, Redis caching, Nginx, Let's Encrypt

This is a demonstration of Nginx used as a proxy for a ColdFusion 2021 application instance. The Nginx service uses a Let's Eencrypt certificate. The Nginx and Let's Encrypt configuration was adapted from [here](https://github.com/evgeniy-khist/letsencrypt-docker-compose).

## Initial Setup

### Prerequisites
1. Docker and Docker Compose are installed
2. You have a domain name
3. You have a server with a publicly routable IP address

### Step 1 - Edit config.env
Edit `DOMAIN` and `CERTBOT_EMAIL` to reflect the domain and email address to use.
To obtain a staging certificate from Lets Encrypt, set `CERTBOT_TEST_CERT=1`. Once comfortable the process works, change this to `0` to get a live (not staging) certificate.
The `acceptEULA` is for Coldfusion and may be left as is.
The `password` is the administrator account for Coldfusion.

[_config.env_](config.env)
```
DOMAIN=yourhostname.fqdn.com
CERTBOT_EMAIL=contact@gmail.com
CERTBOT_TEST_CERT=1
CERTBOT_RSA_KEY_SIZE=4096
acceptEULA=YES
password=CF123
configureExternalAddons=true
externalSessionsHost=cache
externalSessionsPort=6379
externalSessionsPassword=eYVX7EwVmmxKPCDmwMtyKVge8oLd2t81
configureExternalSessions=true
addonsHost=cfaddons
addonsPort=8993
installModules=caching,redissessionstorage
```
### Step 2 - Create necessary Docker volumes
```bash
docker volume create --name=nginx_conf
docker volume create --name=letsencrypt_certs
```
### Step 3 - Build images and start containers

Build and run as daemon
```bash
docker compose up -d --build
```
After a bit (minute or two), you should be able to get to the following URLs:

1. Test Page [https://yourhostname.fqdn.com/test.cfm](https://yourhostname.fqdn.com/test.cfm)
2. Dump server Page [https://yourhostname.fqdn.com/dumpserver.cfm](https://yourhostname.fqdn.com/dumpserver.cfm)

The CF Admin page should be available on the system running the containers at this link: [http://localhost:8500/CFIDE/administrator/index.cfm](http://localhost:8500/CFIDE/administrator/index.cfm).

### Step 3.1
Check logs after containers are up
```bash
docker compose logs -f
```

### Step 4 - Stop 
Stop the containers
```bash
docker compose down
```

## Get Production Lets Encrypt Cert

### Step 1 - Update config

Set `CERTBOT_TEST_CERT=0` in [`config.env`](config.env)

### Step 2 - Update docker containers
```bash
docker compose down
docker volume rm letsencrypt_certs
docker volume create --name=letsencrypt_certs
docker compose up -d
```

## Change Domain Name

### Step 1 - Update config

Change the domain name in [`config.env`](config.env)

### Step 2 - Update docker containers

```bash
docker compose down
docker volume rm nginx_conf
docker volume rm letsencrypt_certs
docker volume create --name=nginx_conf
docker volume create --name=letsencrypt_certs
docker compose up -d
```

## Docker Cleanup
Prune things [https://docs.docker.com/config/pruning/](https://docs.docker.com/config/pruning/)
```bash
docker image prune
docker container prune
docker volume prune
```

## Project structure
- [`docker-compose.yml`](docker-compose.yml)
- [`config.env`](config.env) - specifies domain name, email, and CF admin password
- [`app/`](app/) - mapped to app folder in coldfusion container
  - [`dumpserver.cfm`](app/dumpserver.cfm)
  - [`test.cfm`](app/test.cfm)
- [`certbot/`](certbot/)
  - [`certbot.sh`](certbot/certbot.sh)
  - [`Dockerfile`](certbot/Dockerfile)
- [`cron/`](cron/)
  - [`Dockerfile`](cron/Dockerfile)
  - [`renew_certs.sh`](cron/renew_certs.sh)
- [`nginx/`](nginx/)
  - [`Dockerfile`](nginx/Dockerfile)
  - [`gzip.conf`](nginx/gzip.conf)
  - [`hsts.conf`](nginx/hsts.conf)
  - [`nginx.sh`](nginx/nginx.sh)
  - [`options-ssl-nginx.conf`](nginx/options-ssl-nginx.conf)
  - [`site.conf.tpl`](nginx/site.conf.tpl) - Template file for nginx site