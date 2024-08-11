## Compose sample application
### Commandbox Lucee standalone application

This is just the most basic demonstration, and while using the "latest" tag is an option, it's not the best. See other examples that show pointing to a specific tag (for a specific update of a specific Lucee version).

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
    lucee: 
        image: ortussolutions/commandbox:lucee5
        volumes:
            - ./app:/app
        ports:
        - "8888:8080"
```

## Deploy with docker compose

```
$ docker compose up -d
 - Network cmdbox-lucee-latest_default    Created                                                                0.0s
 - Container cmdbox-lucee-latest-lucee-1  Created                                                                0.1s
```

## Expected result

Listing containers must show one container running and the port mapping as below (note that the version reported may differ for you, in using the "latest" tag):
```
$ docker ps
CONTAINER ID   IMAGE                COMMAND             CREATED          STATUS          PORTS                              NAMES
98446b4b8ee5   ortussolutions/commandbox:lucee5               "/bin/sh -c $BUILD_D…"   52 seconds ago   Up 51 seconds (health: starting)   8443/tcp, 0.0.0.0:8888->8080/tcp                           cmdbox-lucee-latest-lucee-1
```

## Running requests

After the application starts, navigate to `http://localhost:8888` in your web browser to run available files placed into Lucee's webroot by default. 

### Default files included with the container

Unless you mount an app into the container (see the next section), the Commandbox Lucee image defaults to providing a few files in that location: index.cfm (a welcome page), 403.html, and CommandBoxLogo300.png.

In that case, you could run `http://localhost:8888/index.cfm` in your web browser to see the test page, or run via curl:
```
$ curl http://localhost:8888/index.cfm
```

### Mounting an app into the container

Optionally, you can copy files into the container webroot (which for Lucee in Commandbox is /app). The can be done by adding a volume mount of a host folder into that containe folder. Those are then what become available as the contents for the root site of the container.

For example, included with this compose file is an app folder, with some test files. The following volumes directive (under the lucee service) would mount those files into the container:
    
            volumes:
            - ./app:/app

You could then run `http://localhost:8888/test.cfm` in your web browser to see the test page, or run via curl:
```
$ curl http://localhost:8888/test.cfm

Which will show:
Hello World! at 03-Jul-2022 21:35:44
```
Or to see a dump of the server scope within the container, navigate to `http://localhost:8888/dumpserver.cfm` in your web browser or run:
```
$ curl http://localhost:8888/dumpserver.cfm
```

To be clear, if you mount or copy in your own files to the /var/www folder, the test.cfm and dumpserver.cfm files won't be available, and instead your own files will be. 

## Accessing the Lucee Admin

The Lucee admin (server and web) are available within the lucee/lucee container via the paths lucee/admin/server.cfm and lucee/admin/web.cfm, respectively--that is if the admins are enabled in the commandbox image. By default, they are not.

If enabled, to access the Lucee Server admin, navigate to `http://localhost:8888/lucee/admin/server.cfm` in your web browser or run:
```
$ curl http://localhost:8888/lucee/admin/server.cfm
```

Or use the same form for the lucee/admin/web.cfm. 

### Setting Lucee Admin password (none defined by default)

As with Lucee itself, for the sake of security, there is no password defined for the Lucee admin(s) in Commandbox by default.

With Lucee images in Commandbox, commandbox offers a cfconfig property to control that, called adminPassword. See the Commandbox docs for more on that. 

## Stop and remove the containers
```
$ docker compose down
```