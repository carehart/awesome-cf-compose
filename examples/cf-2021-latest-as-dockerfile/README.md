## Sample application
### ColdFusion standalone application

Project structure:
```
.
├── Dockerfile 
├── app
    └── test.cfm
    └── dumpserver.cfm
```

[_Dockerfile_](Dockerfile)
```
FROM adobecoldfusion/coldfusion2021:latest
ENV acceptEULA=YES password=123
COPY ./app /app
```

## Deploy with docker build and run

```
$ docker build -t test-app .
[+] Building 0.1s (7/7) FINISHED                                                                   docker:desktop-linux
 => [internal] load build definition from Dockerfile                                                               0.0s
 => => transferring dockerfile: 129B                                                                               0.0s
 => WARN: SecretsUsedInArgOrEnv: Do not use ARG or ENV instructions for sensitive data (ENV "password") (line 2)   0.0s
...

$ >docker run -p 8500:8500 --name test-app test-app

Updating webroot to /app
Configuring virtual directories
Updating password
Skipping language updation
Serial Key: Not Provided
Previous Serial Key: Not Provided
Starting ColdFusion
Starting ColdFusion 2021 server
...
```

## Expected result

Listing containers must show one container running and the port mapping as below (note that the version reported may differ for you, in using the "latest" tag):
```
$ docker ps
CONTAINER ID   IMAGE                         COMMAND                  CREATED              STATUS                        PORTS                                         NAMES
77ba8110b3b6   test-app                      "sh /opt/startup/sta…"   About a minute ago   Up About a minute (healthy)   0.0.0.0:8500->8500/tcp, [::]:8500->8500/tcp   test-app

```

After the application starts, navigate to `http://localhost:8500` in your web browser to see available files in CF's default webroot (added to by the /app volume mapping)

Or run `http://localhost:8500/test.cfm` in your web browser to see the test page in the mapped /app folder, or run via curl:
```
$ curl http://localhost:8500/test.cfm

Which will show:
Hello World! at 08-Jun-2026 13:58:45
```
Run this to see a dump of the server.coldfusion struct within the container: navigate to `http://localhost:8500/dumpserver.cfm` in your web browser or run:
```
$ curl http://localhost:8500/dumpserver.cfm
```

Stop and remove the containers
```
$ docker stop test-app
$ docker rm test-app

```
