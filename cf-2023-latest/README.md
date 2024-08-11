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
        image: adobecoldfusion/coldfusion2023:latest
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
 ✔ Network cf-2023-latest_default         Created                                                                  0.0s
 ✔ Container cf-2023-latest-coldfusion-1  Created                                                                  0.0s
Attaching to coldfusion-1
coldfusion-1  | Updating webroot to /app
coldfusion-1  | Configuring virtual directories
coldfusion-1  | Updating password
coldfusion-1  | Skipping language updation
coldfusion-1  | Serial Key: Not Provided
coldfusion-1  | Previous Serial Key: Not Provided
coldfusion-1  | Starting ColdFusion
coldfusion-1  | Starting ColdFusion 2023 server ...
coldfusion-1  | ======================================================================
coldfusion-1  | ColdFusion 2023 server has been started.
coldfusion-1  | ColdFusion 2023 will write logs to /opt/coldfusion/cfusion/bin/../logs/coldfusion-out.log
coldfusion-1  | ======================================================================
coldfusion-1  | [] Checking server startup status...
coldfusion-1  | No Modules to be installed !
coldfusion-1  | No Settings to be imported !
coldfusion-1  | No Modules to be imported !
coldfusion-1  |   % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
coldfusion-1  |                                  Dload  Upload   Total   Spent    Left  Speed
  0     0    0     0    0     0      0      0 --:--:-- --:--:-- --:--:--     0
coldfusion-1  | External Addons: Disabled
coldfusion-1  | External Session Storage: Disabled
coldfusion-1  | Skipping setup script invocation
coldfusion-1  | Secure Profile: Disabled
coldfusion-1  | Deployment Type not set , set to default(Development)
coldfusion-1  | Profile not set , set to default(Development Profile)
coldfusion-1  | Cleaning up setup directories
coldfusion-1  | restart required:
coldfusion-1  | 0
coldfusion-1  | Aug 11, 2024 03:48:13 AM Information [main] - gcpfirestore package will not be deployed as it is not installed.
coldfusion-1  | Aug 11, 2024 03:48:13 AM Information [main] - gcppubsub package will not be deployed as it is not installed.
coldfusion-1  | Aug 11, 2024 03:48:13 AM Information [main] - gcpstorage package will not be deployed as it is not installed.
coldfusion-1  | Aug 11, 2024 03:48:13 AM Information [main] - report package will not be deployed as it is not installed.
coldfusion-1  | Aug 11, 2024 03:48:13 AM Information [main] - exchange package will not be deployed as it is not installed.
coldfusion-1  | Aug 11, 2024 03:48:13 AM Information [main] - sharepoint package will not be deployed as it is not installed.
coldfusion-1  | Aug 11, 2024 03:48:13 AM Information [main] - graphqlclient package will not be deployed as it is not installed.
coldfusion-1  | Aug 11, 2024 03:48:13 AM Information [main] - ColdFusion started
...
```

## Expected result

Listing containers must show one container running and the port mapping as below (note that the version reported may differ for you, in using the "latest" tag):
```
$ docker ps
CONTAINER ID   IMAGE                                   COMMAND                  CREATED         STATUS                   PORTS                                                   NAMES
be19b9f1d225   adobecoldfusion/coldfusion2023:latest   "sh /opt/startup/sta…"   2 minutes ago   Up 2 minutes (healthy)   7071/tcp, 8122/tcp, 45564/tcp, 0.0.0.0:8500->8500/tcp   cf-2023-latest-coldfusion-1
```

After the application starts, navigate to `http://localhost:8500` in your web browser to see available files in CF's default webroot (added to by the /app volume mapping)

Or run `http://localhost:8500/test.cfm` in your web browser to see the test page in the mapped /app folder, or run via curl:
```
$ curl http://localhost:8500/test.cfm

Which will show:
Hello World! at 11-Aug-2024 03:50:35
```
Run this to see a dump of the server.coldfusion struct within the container: navigate to `http://localhost:8500/dumpserver.cfm` in your web browser or run:
```
$ curl http://localhost:8500/dumpserver.cfm
```

Stop and remove the containers
```
$ docker-compose down
```