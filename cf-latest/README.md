## Compose sample application
### ColdFusion standalone application

This is just the most basic demonstration, and while using the "latest" tag is an option, it's not the best. See other examples that show pointing to a specific tag (for a specific update of a specific CF version).

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
        image: adobecoldfusion/coldfusion2021:latest
        ports:
        - "8500:8500"
        environment:
            - acceptEULA=YES
            - password=123
        volumes:
            - ./app:/app
```

## Deploy with docker-compose

```
$ docker-compose up -d
- Network cf-latest_default         Created                                                                       0.8s
 - Container cf-latest-coldfusion-1  Created                                                                       0.2s
Attaching to cf-latest-coldfusion-1
cf-latest-coldfusion-1  | Updating webroot to /app
cf-latest-coldfusion-1  | Configuring virtual directories
cf-latest-coldfusion-1  | Updating password
cf-latest-coldfusion-1  | Skipping language updation
cf-latest-coldfusion-1  | Serial Key: Not Provided
cf-latest-coldfusion-1  | Previous Serial Key: Not Provided
cf-latest-coldfusion-1  | Starting ColdFusion
...
```

## Expected result

Listing containers must show one container running and the port mapping as below (note that the version reported may differ for you, in using the "latest" tag):
```
$ docker ps
CONTAINER ID        IMAGE                                                    COMMAND                  CREATED              STATUS                        PORTS                                         NAMES
d935f819f622        adobecoldfusion/coldfusion2021:latest   "sh /opt/startup/sta…"   About a minute ago   Up About a minute (healthy)   8118/tcp, 45564/tcp, 0.0.0.0:8500->8500/tcp   cf-latest_coldfusion_1

```

After the application starts, navigate to `http://localhost:8500` in your web browser to see available files in CF's default webroot (added to by the /app volume mapping)

Or run `http://localhost:8500/test.cfm` in your web browser to see the test page in the mapped /app folder, or run via curl:
```
$ curl http://localhost:8500/test.cfm

Which will show:
Hello World! at 03-Oct-2021 02:35:44
```
Run this to see a dump of the server.coldfusion struct within the container: navigate to `http://localhost:8500/dumpserver.cfm` in your web browser or run:
```
$ curl http://localhost:8500/dumpserver.cfm
```

Stop and remove the containers
```
$ docker-compose down
```