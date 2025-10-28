## Compose sample application
### ColdFusion standalone application

Project structure:
```
.
├── compose.yaml
├── app
    └── test.cfm
    └── dumpserver.cfm

```

[_compose.yaml_](compose.yaml)
```
services:
    coldfusion: 
        image: adobecoldfusion/coldfusion2025:latest
        ports:
        - "8500:8500"
        environment:
            - acceptEULA=YES
            - password=123
        volumes:
            - ./app:/app
```

## Deploy with docker compose

```
$ docker compose up -d
[+] Running 2/2
 ✔ Network cf-2025-latest_default         Created                                                                  0.2s
 ✔ Container cf-2025-latest-coldfusion-1  Started                                                                  1.0s

## Expected result

Listing containers must show one container running and the port mapping as below (note that the version reported may differ for you, in using the "latest" tag):
```
$ docker ps
CONTAINER ID   IMAGE                                   COMMAND                  CREATED              STATUS                        PORTS                                         NAMES
6579a55a0028   adobecoldfusion/coldfusion2025:latest   "/bin/bash /opt/star…"   About a minute ago   Up About a minute (healthy)   0.0.0.0:8500->8500/tcp, [::]:8500->8500/tcp   cf-2025-latest-coldfusion-1
```

After the application starts, navigate to `http://localhost:8500` in your web browser to see available files in CF's default webroot (added to by the /app volume mapping)

Or run `http://localhost:8500/test.cfm` in your web browser to see the test page in the mapped /app folder, or run via curl:
```
$ curl http://localhost:8500/test.cfm

Which will show:
Hello World! at 27-Oct-2025 19:30:35
```
Run this to see a dump of the server.coldfusion struct within the container: navigate to `http://localhost:8500/dumpserver.cfm` in your web browser or run:
```
$ curl http://localhost:8500/dumpserver.cfm
```

Stop and remove the containers
```
$ docker compose down
```