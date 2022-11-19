## Compose sample application
### ColdFusion standalone application with Nginx and Let's Encrypt Certificate

This is a demonstration of fronting CF with nginx as the web server, with an automatic renewing Let's encrypt certificate. The Nginx and Let's Encrypt configuration came from [here](https://github.com/evgeniy-khist/letsencrypt-docker-compose)

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
```
## Initial Setup

### Step 1 - Edit domain names and emails in config.env
Edit `DOMAINS` and `CERTBOT_EMAILS` to reflect the domain and email address to use.
To get a test certificate from Lets Encrypt, set `CERTBOT_TEST_CERT=1`.


[_config.env_](config.env)
```
DOMAINS=jandk.bounceme.net
CERTBOT_EMAILS=jandkbouncemeinfo@gmail.com
CERTBOT_TEST_CERT=1
CERTBOT_RSA_KEY_SIZE=4096
```
### Step 2 - Create Docker volumes for dummy and Let's Encrypt TLS certificates
```
docker volume create --name=nginx_conf
docker volume create --name=letsencrypt_certs
```
### Step 3 - Build images and start containers
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
### Step 4 - Clean up 
Prune various things https://docs.docker.com/config/pruning/
```
docker image prune
docker container prune
docker volume prune
```

## Expected result

Listing containers show one container running and the port mapping as below (note that the version reported may differ for you, in using the "latest" tag):
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
```
Which will show:
```
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