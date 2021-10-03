## Compose sample application
### ColdFusion standalone application

Project structure:
```
.
├── docker-compose.yml
├── app
    └── test.cfm
    └── dumpserver.cfm

```

[_docker-compose.yml_](docker-compose.yml)
```
services:
    coldfusion: 
        image: adobecoldfusion/coldfusion2021:2021.0.2
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
cf-2021-coldfusion-1  | Updating webroot to /app
cf-2021-coldfusion-1  | Configuring virtual directories
cf-2021-coldfusion-1  | Updating password
cf-2021-coldfusion-1  | Serial Key: Not Provided       
cf-2021-coldfusion-1  | Previous Serial Key: Not Provided
cf-2021-coldfusion-1  | Starting ColdFusion
...
cf-2021-coldfusion-1  | Oct 3, 2021 01:31:10 AM Information [main] - ColdFusion started
cf-2021-coldfusion-1  | Oct 3, 2021 01:31:10 AM Information [main] - ColdFusion: application services are now available        
cf-2021-coldfusion-1  | Oct 3, 2021 01:31:11 AM Information [http-nio-8500-exec-1] - Initialize client.properties file
```

## Expected result

Listing containers must show one container running and the port mapping as below:
```
$ docker ps
CONTAINER ID        IMAGE                                                    COMMAND                  CONTAINER ID   IMAGE                                     COMMAND                  CREATED          STATUS                    PORTS                                         NAMES
a7df2d9ffc26   adobecoldfusion/coldfusion2021:2021.0.2   "sh /opt/startup/sta…"   56 minutes ago   Up 54 minutes (healthy)   8118/tcp, 45564/tcp, 0.0.0.0:8500->8500/tcp   cf-2021-coldfusion-1
```

After the application starts, navigate to `http://localhost:8500` in your web browser to see available files in CF's default webroot (added to by the /app volume mapping)

Or run `http://localhost:8500/test.cfm` in your web browser to see the test page in the mapped /app folder, or run via curl:
```
$ curl http://localhost:8500/test.cfm

Which will show:
Hello World! at 03-Oct-2021 02:25:44
```
Run this to see dump of server scope within container: navigate to `http://localhost:8500/dumpserver.cfm` in your web browser or run:
```
$ curl http://localhost:8500/dumpserver.cfm
```

Stop and remove the containers
```
$ docker-compose down
```