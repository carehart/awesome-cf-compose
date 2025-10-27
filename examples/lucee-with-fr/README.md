## Compose sample application
### Lucee standalone application

This is just the most basic demonstration, and while using the "latest" tag is an option, it's not the best. See other examples that show pointing to a specific tag (for a specific update of a specific Lucee version).

Project structure:
```
.
├── Dockerfile
├── compose.yaml
├── app
├── app
    └── test.cfm
    └── dumpserver.cfm

```

[_compose.yaml_](compose.yaml)
```
services:
    lucee: 
        image: lucee/lucee:latest
        ports:
        - "8888:8888"
```

## Deploy with docker compose

```
$ docker compose up -d
 - Network lucee-latest_default    Created                                                                         0.0s
 - Container lucee-latest-lucee-1  Started                                                                         0.3s

```

## Expected result

Listing containers must show one container running and the port mapping as below (note that the version reported may differ for you, in using the "latest" tag):
```
$ docker ps
CONTAINER ID   IMAGE                COMMAND             CREATED          STATUS          PORTS                              NAMES
dfc208f9368c   lucee/lucee:latest   "catalina.sh run"   37 seconds ago   Up 36 seconds   8080/tcp, 0.0.0.0:8888->8888/tcp   lucee-latest-lucee-1
```

## Running requests

After the application starts, navigate to `http://localhost:8888` in your web browser to run available files placed into Lucee's webroot by default. 

### Default files included with the container

Unless you mount an app into the container (see the next section), the Lucee image defaults to providing a few files in that location: index.cfm (a welcome page), debug.cfm (dumping various scopes), an Application.cfc, and a favicon.ico.

If you run the URL in the previous section, then you would see the welcome page (at index.cfm) by default. To see the debug page, you could run `http://localhost:8888/debug.cfm` in your web browser to see the test page, or run via curl:
```
$ curl http://localhost:8888/debug.cfm
```

### Mounting an app into the container

Optionally, you can copy files into the container webroot (/var/www). The can be done by adding a volume mount of a host folder into that containe folder. Those are then what become available as the contents for the root site of the container.

For example, included with this compose file is an app folder, with some test files. The following volumes directive (under the lucee service) would mount those files into the container:
    
            volumes:
            - ./app:/var/www

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

The Lucee admin (server and web)are available within the lucee/lucee container via the paths lucee/admin/server.cfm and lucee/admin/web.cfm, respectively.

To access the Lucee Server admin, navigate to `http://localhost:8888/lucee/admin/server.cfm` in your web browser or run:
```
$ curl http://localhost:8888/lucee/admin/server.cfm
```

Or use the same form for the lucee/admin/web.cfm. 

### Setting Lucee Admin password (none defined by default)

As with Lucee itself, for the sake of security, there is no password defined for the Lucee admin(s) by default. With traditional Lucee deployment, you would create a file called password.txt and place that in the deployment's /lucee-server/context/password.txt file.

With containers, we can instead place that file inside the container either via a dockerfile using COPY or via a compose file bind-mounting that file into the container. This compose files shows the latter:

    lucee: 
        image: lucee/lucee:latest
        ports:
        - "8888:8888"
        volumes:
            - type: bind
              source: ./lucee-admin-password/password.txt
              target: /opt/lucee/server/lucee-server/context/password.txt

Note that this can't be implemented as a "shorthand" bind like the other one above (for /var/www). Doing that in this case would would cause docker to create a two-way mount, where all files in the container in that /opt/lucee/server/lucee-server/context folder would be copied also into your host under that lucee-admin-password folder, which is definitely NOT what we want in this simple case of wanting to copy this one file INTO the container.

## Setting java options

To set java options within the container (such as to control the heap size, garbage collection args, etc), you can use the environment variable called LUCEE_JAVA_OPTS (the name is case-sensitive). Here is an example of doing that.

Note that as of Lucee 5.3.9.141, this value defaults to: -Xms64m -Xmx512m. If you specify one but not the other, the value will depend on the JVM. For instance, with the Java 11.0.15 that comes with that Lucee image version, setting the Xmx only will by default set the Xms to the same value.

    lucee: 
        image: lucee/lucee:latest
        ports:
        - "8888:8888"
        environment:
        - LUCEE_JAVA_OPTS=-Xmx1024m 


## Stop and remove the containers
```
$ docker compose down
```