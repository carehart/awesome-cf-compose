## Compose sample application
### ColdFusion standalone application

Project structure:
```
.
├── docker-compose.yml
├── Dockerfile
├── app
    └── test.cfm
    └── dumpserver.cfm

```

[_docker-compose.yml_](docker-compose.yml)
```
FROM adobecoldfusion/coldfusion2021:latest

RUN mkdir -p /opt/fusionreactor

ADD https://download.fusionreactor.io/FR/Latest/fusionreactor.jar /opt/fusionreactor/fusionreactor.jar
ADD https://download.fusionreactor.io/FR/Latest/libfrjvmti_x64.so /opt/fusionreactor/libfrjvmti_x64.so

# i found that FR would not start unless I made this permissions change
RUN chmod -R o=rwx /opt/fusionreactor/
```

[_docker-compose.yml_](docker-compose.yml)
```
services:
    coldfusion:
        build: . 
        ports:
        - "8500:8500"
        - "8088:8088"
        environment:
            - acceptEULA=YES
            - password=123
            - _JAVA_OPTIONS=-javaagent:"/opt/fusionreactor/fusionreactor.jar=name=lucee-fr,address=8088"
        volumes:
            - ./app:/app```
```

## Deploy with docker-compose

```
$ docker-compose up -d
 - Network cf-2021-latest-fr_default         Created                                                                0.0s
 - Container cf-2021-latest-fr-coldfusion-1  Created                                                                0.0s
Attaching to cf-2021-latest-fr-coldfusion-1
cf-2021-latest-fr-coldfusion-1  | Updating webroot to /app
cf-2021-latest-fr-coldfusion-1  | Configuring virtual directories
cf-2021-latest-fr-coldfusion-1  | Updating password
...
cf-2021-latest-fr-coldfusion-1  | Starting ColdFusion
cf-2021-latest-fr-coldfusion-1  | Starting ColdFusion 2021 server ...
cf-2021-latest-fr-coldfusion-1  | Picked up _JAVA_OPTIONS: -javaagent:"/opt/fusionreactor/fusionreactor.jar=name=lucee-fr,address=8088"
cf-2021-latest-fr-coldfusion-1  | ======================================================================
cf-2021-latest-fr-coldfusion-1  | ColdFusion 2021 server has been started.
```

## Expected result

Listing containers must show one container running and the port mapping as below (note that the version reported may differ for you, in using the "latest" tag):
```
$ docker ps
CONTAINER ID   IMAGE                                     COMMAND                  CREATED          STATUS                    PORTS                                         NAMES
b3c41fac7599   cf-2021-latest-fr_coldfusion   "sh /opt/startup/sta…"   About a minute ago   Up About a minute (healthy)   0.0.0.0:8088->8088/tcp, 8118/tcp, 0.0.0.0:8500->8500/tcp, 45564/tcp   cf-2021-latest-fr-coldfusion-1
```

After the application starts, navigate to `http://localhost:8500` in your web browser to see available files in CF's default webroot (added to by the /app volume mapping)

See readme in [cf-latest/README.md](../cf-latest/README.md) folder for more.

Run `http://localhost:8088` in your web browser to see the FusionReactor login page, or run via curl:
```
$ curl http://localhost:8088/
```

Stop and remove the containers
```
$ docker-compose down
```