## Compose sample application
### ColdFusion standalone application

This is a demonstration of fronting CF with nginx as the web server. As such, note that it will listen on the port indicated below for nginx (4000). You could of course modify the `docker-compose.yml` and the `nginx.conf` files to name a different port, or even use port 80. I leave you to explore [the docs for the nginx image](https://hub.docker.com/_/nginx) for more on its capabilities.

Note how the example still uses an /app folder (mounted as a volume within the CFML container), in which CFML code can be placed, and that code can of course be executed using the nginx port. 

Note also how the nginx.conf has been configured to BLOCK access to the CFIDE folder. If that was NOT done, then that folder (and the CF Admin) WOULD be accessible using that nginx port. (As for the cf_scripts folder, and the old concern that blocking the CFIDE folder would block also access to that, note that since CF2016 that cf_scripts folder is now a SIBLING to the CFIDE folder, and it's accessible via EITHER the nginx or CF's built-in web server port.)

Project structure:
```
.
├── docker-compose.yml
├── nginx.conf
├── README.md
├── app
    └── test.cfm
    └── dumpserver.cfm

```

[_docker-compose.yml_](docker-compose.yml)
```
services:
    coldfusion: 
        image: adobecoldfusion/coldfusion2021:latest
        expose:
            - "8500:8500"
        environment:
            - acceptEULA=YES
            - password=123
        volumes:
            - ./app:/app
    nginx:
        image: nginx:latest
        volumes:
          - ./nginx.conf:/etc/nginx/nginx.conf:ro
        depends_on:
          - coldfusion
        ports:
        - "4000:4000"
```

[_nginx.conf_](nginx.conf)
```
user  nginx;

events {
    worker_connections   1000;
}
http {
        server {
              listen 4000;
              location ~ /CFIDE {
                    return 403;
              }
              location / {
                proxy_pass http://coldfusion:8500;
              }
        }
}
```

## Deploy with docker-compose

```
$ docker-compose up -d
- Network cf-nginx_default         Created                                                                       0.8s
 - Container cf-nginx-coldfusion-1  Created                                                                       0.2s
 - Container cf-nginx-nginx-1  Created                                                                       0.2s
```

## Expected result

Listing containers must show one container running and the port mapping as below (note that the version reported may differ for you, in using the "latest" tag):
```
$ docker ps
CONTAINER ID        IMAGE                                                    COMMAND        CREATED              STATUS                        PORTS                                         NAMES
11fe9e4a15c0        nginx:latest                                   "/docker-entrypoint.…"   About a minute ago     Up About a minute             80/tcp, 0.0.0.0:4000->4000/tcp                cf-nginx-nginx-1
d935f819f622        adobecoldfusion/coldfusion2021:latest          "sh /opt/startup/sta…"   About a minute ago   Up About a minute (healthy)      8118/tcp, 45564/tcp, 0.0.0.0:8500->8500/tcp   cf-latest_coldfusion_1

```

After the application starts, navigate to `http://localhost:4000` in your web browser to see available files in CF's default webroot (added to by the /app volume mapping).

If you attempt to run the CF Administrator, as `localhost:4000/administrator/index.cfm`, note that this will fail with a `403 forbidden` error. Again, you can still access the CF Admin using `localhost:8500/administrator/index.cfm`.

Or run `http://localhost:4000/test.cfm` in your web browser to see the test page in the mapped /app folder, or run via curl:
```
$ curl http://localhost:4000/test.cfm

Which will show:
Hello World! at 03-Oct-2021 02:35:44
```
Run this to see a dump of the server.coldfusion struct within the container: navigate to `http://localhost:4000/dumpserver.cfm` in your web browser or run:
```
$ curl http://localhost:4000/dumpserver.cfm
```

Stop and remove the containers
```
$ docker-compose down
```