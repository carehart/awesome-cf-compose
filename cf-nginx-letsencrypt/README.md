## Compose sample application
### ColdFusion standalone application with Nginx and Let's Encrypt

This is a demonstration of fronting CF with nginx as the web server, with an automatic renewing let's encrypt certificate. The Nginx and Let's Encrypt configuration came from [here](https://github.com/evgeniy-khist/letsencrypt-docker-compose)

Note how the example still uses an /app folder (mounted as a volume within the CFML container), in which CFML code can be placed, and that code can of course be executed using the nginx port. 

Note also how the nginx.conf has been configured to BLOCK access to the CFIDE folder. If that was NOT done, then that folder (and the CF Admin) WOULD be accessible using that nginx port. (As for the cf_scripts folder, and the old concern that blocking the CFIDE folder would block also access to that, note that since CF2016 that cf_scripts folder is now a SIBLING to the CFIDE folder, and it's accessible via EITHER the nginx or CF's built-in web server port.)

Project structure:
```
.
├── docker-compose.yml
├── config.env
├── README.md
├── app
    └── test.cfm
    └── dumpserver.cfm
├── certbot
    └── certbot.sh
    └── Dockerfile
├── cron
    └── Dockerfile
    └── renew_certs.sh
├── nginx
    └── default.conf
    └── Dockerfile
    └── gzip.conf
    └── hsts.conf
    └── nginx.sh
    └── options-ssl-nginx.conf
    └── site.conf.tpl
├── vhosts
    └── jandk.bounceme.net.conf
```

[_docker-compose.yml_](docker-compose.yml)
```
version: "3"

services:
  coldfusion: 
    image: adobecoldfusion/coldfusion2021:latest
    ports:
        - "8500:8500"
    environment:
        - acceptEULA=YES
        - password=123
    volumes:
        - ./app:/app

  nginx:
    build: ./nginx
    image: nginx:1.23-alpine
    env_file:
      - ./config.env
    volumes:
      - nginx_conf:/etc/nginx/sites
      - letsencrypt_certs:/etc/letsencrypt
      - certbot_acme_challenge:/var/www/certbot
      - ./vhosts:/etc/nginx/vhosts
      - ./html:/var/www/html
    depends_on:
      - coldfusion
    ports:
    - "80:80"
    - "443:443"
    - "4000:4000"
    restart: unless-stopped

  certbot:
    build: ./certbot
    image: certbot/certbot:v1.29.0
    env_file:
      - ./config.env
    volumes:
      - letsencrypt_certs:/etc/letsencrypt
      - certbot_acme_challenge:/var/www/certbot

  cron:
    build: ./cron
    image: evgeniy-khyst/cron
    environment:
      COMPOSE_PROJECT_NAME: "${COMPOSE_PROJECT_NAME}"
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
      - ./:/workdir:ro
    restart: unless-stopped

volumes:
  nginx_conf:
    external: true
  letsencrypt_certs:
    external: true
  certbot_acme_challenge:
```

## Initial Setup

### Step 1 - Edit domain names and emails in config.env
For the first go around we will be getting test cert(s), so `CERTBOT_TEST_CERT=1`.

[_config.env_](config.env)
```
DOMAINS=jandk.bounceme.net
CERTBOT_EMAILS=jandkbouncemeinfo@gmail.com
CERTBOT_TEST_CERT=1
CERTBOT_RSA_KEY_SIZE=4096
```
For multiple domains, use space as delimiter:
[_config.env_](config.env)
```
DOMAINS="jandk.bounceme.net jandk2.bounceme.net"
CERTBOT_EMAILS="jandkbouncemeinfo@gmail.com jandkbouncemeinfo@gmail.com"
```

### Step 2 - Configure virtual hosts
For each domain, update the `vhosts/${domain].conf` file:
- vhosts/jandk.bounceme.net.conf

### Step 3 - Create Docker volumes for dummy and Let's Encrypt TLS certificates
```
docker volume create --name=nginx_conf
docker volume create --name=letsencrypt_certs
```
### Step 4 - Build images and start containers using staging Let's Encrypt server
Build and run as daemon
```
docker compose up -d --build
```
Build with no cache and don't run
```
docker compose build --no-cache
```
Check logs after containers are up
```
docker compose logs -f
```
## Expected result

Listing containers must show one container running and the port mapping as below (note that the version reported may differ for you, in using the "latest" tag):
```
❯ docker ps
CONTAINER ID   IMAGE                                   COMMAND                  CREATED          STATUS                    PORTS                                                              NAMES
b60bd06d184b   nginx:1.23-alpine                       "/docker-entrypoint.…"   30 minutes ago   Up 30 minutes             0.0.0.0:80->80/tcp, 0.0.0.0:443->443/tcp, 0.0.0.0:4000->4000/tcp   cf-nginx-letsencrypt-nginx-1
193c8d96fa93   evgeniy-khyst/cron                      "crond -f -l 0"          30 minutes ago   Up 30 minutes                                                                                cf-nginx-letsencrypt-cron-1
c044e230fa67   adobecoldfusion/coldfusion2021:latest   "sh /opt/startup/sta…"   30 minutes ago   Up 30 minutes (healthy)   8118/tcp, 45564/tcp, 0.0.0.0:8500->8500/tcp                        cf-nginx-letsencrypt-coldfusion-1
```

After the application starts, navigate to `https://localhost` in your web browser to see available files in CF's default webroot (added to by the /app volume mapping). You can access the CF Admin using `localhost:8500/administrator/index.cfm`.

Run `https://yourhostname.fqdn.com/test.cfm` in your web browser to see the test page in the mapped /app folder, or run via curl:
```
$ curl https://yourhostname.fqdn.com/test.cfm

Which will show:
Hello World! at 03-Oct-2021 02:35:44
```
Run this to see a dump of the server.coldfusion struct within the container: navigate to `https://yourhostname.fqdn.com/dumpserver.cfm` in your web browser or run:
```
$ curl https://yourhostname.fqdn.com/dumpserver.cfm
```

Stop and remove the containers
```
$ docker-compose down
```