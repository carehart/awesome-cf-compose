## Compose sample application
### Commandbox ColdFusion standalone application

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
        # note that the generic commandbox image is called, but then specifically the jdk21 tag which is needed for CF2025.
        # the CF version is set via the BOX_SERVER_APP_CFENGINE env var below
        image: ortussolutions/commandbox:jdk21
        volumes:
            - ./app:/app
        ports:
        - "8888:8080"
        environment:
        # set the CF version and update level, via an env var.
        # See the commandbox docs for the format of available values, at:
        # https://commandbox.ortusbooks.com/embedded-server/multi-engine-support#server.json-configuration
        - BOX_SERVER_APP_CFENGINE=adobe@2025
        # if you want to see a CF admin, you must enable the commandbox "development" profile
        - BOX_SERVER_PROFILE=development
        # if you want to set a password in this file, set the next variable:
        - cfconfig_adminPassword=testing123
```

## Deploy with docker compose

```
$ docker compose up -d
  ✔ Network cmdbox-cf2025-via-cfengine_default         Created                                                      0.2s
 ✔ Container cmdbox-cf2025-via-cfengine-coldfusion-1  Start...                                                     0.9s
```

## Expected result

Listing containers must show one container running and the port mapping as below (note that the version reported may differ for you, in using the "latest" tag):
```
$ docker ps
CONTAINER ID   IMAGE                COMMAND             CREATED          STATUS          PORTS                              NAMES
78d775c5b33a   ortussolutions/commandbox:jdk21   "/__cacert_entrypoin…"   52 seconds ago   Up 52 seconds (health: starting)   0.0.0.0:8888->8080/tcp, [::]:8888->8080/tcp   cmdbox-cf2025-via-cfengine-coldfusion-1
```

### Mounting an app into the container

You can copy files into the container webroot (which for CF in Commandbox is /app). The can be done by adding a volume mount of a host folder into that containe folder. Those are then what become available as the contents for the root site of the container.

For example, included with this compose file is an app folder, with some test files. The following volumes directive (under the coldfusion service) would mount those files into the container:
    
            volumes:
            - ./app:/app

You could then run `http://localhost:8888/test.cfm` in your web browser to see the test page, or run via curl:
```
$ curl http://localhost:8888/test.cfm

Which will show:
Hello World! at 01-Nov-2025 04:16:13
```
Or to see a dump of the server scope within the container, navigate to `http://localhost:8888/dumpserver.cfm` in your web browser or run:
```
$ curl http://localhost:8888/dumpserver.cfm
```

To be clear, if you mount or copy in your own files to the /var/www folder, the test.cfm and dumpserver.cfm files won't be available, and instead your own files will be. 

## Accessing the CF Admin, setting Admin password

The CF admin can be made available within the Commandbox CF container. See the compose.yaml file for how to optionally enable the admin (using the BOX_SERVER_PROFILE=development env var) as well as set a CF admin password (using the cfconfig_adminPassword).

If enabled, to access the CF admin, navigate to `http://localhost:8888/CFIDE/administrator/index.cfm` in your web browser or run:
```
$ curl http://localhost:8888/CFIDE/administrator/index.cfm
```

## Stop and remove the containers
```
$ docker compose down
```