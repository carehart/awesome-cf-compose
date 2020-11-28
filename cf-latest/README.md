## Compose sample application
### ColdFusion standalone application

Project structure:
```
.
├── docker-compose.yaml
├── app
    └── test.cfm

```

[_docker-compose.yml_](docker-compose.yml)
```
services:
    coldfusion: 
        image: eaps-docker-coldfusion.bintray.io/cf/coldfusion:latest
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
Creating network "cf-latest_default" with the default driver
Creating cf-latest_coldfusion_1 ... done
Attaching to cf-latest_coldfusion_1
coldfusion_1  | Updating webroot to /app
coldfusion_1  | Configuring virtual directories
coldfusion_1  | Updating password
coldfusion_1  | Skipping language updation
coldfusion_1  | Serial Key: Not Provided
coldfusion_1  | Previous Serial Key: Not Provided
coldfusion_1  | Starting ColdFusion
coldfusion_1  | Starting ColdFusion 2021 server ...
coldfusion_1  | ======================================================================
coldfusion_1  | ColdFusion 2021 server has been started.
coldfusion_1  | ColdFusion 2021 will write logs to /opt/ColdFusion/cfusion/bin/../logs/coldfusion-out.log
coldfusion_1  | ======================================================================
coldfusion_1  | [000] Checking server startup status...
coldfusion_1  | No Modules to be installed !
coldfusion_1  | No Settings to be imported !
coldfusion_1  | No Modules to be imported !
coldfusion_1  |   % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
coldfusion_1  |                                  Dload  Upload   Total   Spent    Left  Speed
  0     0    0     0    0     0      0      0 --:--:-- --:--:-- --:--:--     0
coldfusion_1  | External Addons: Disabled
coldfusion_1  | External Session Storage: Disabled
coldfusion_1  | Skipping setup script invocation
```

## Expected result

Listing containers must show one container running and the port mapping as below:
```
$ docker ps
CONTAINER ID        IMAGE                                                    COMMAND                  CREATED              STATUS                        PORTS                                         NAMES
d935f819f622        eaps-docker-coldfusion.bintray.io/cf/coldfusion:latest   "sh /opt/startup/sta…"   About a minute ago   Up About a minute (healthy)   8118/tcp, 45564/tcp, 0.0.0.0:8500->8500/tcp   cf-latest_coldfusion_1

```

After the application starts, navigate to `http://localhost:8500` in your web browser to see available files in CF's default webroot (added to by the /app volume mapping)

Or run `http://localhost:8500/test.cfm` in your web browser to see the test page in the mapped /app folder, or run via curl:
```
$ curl http://localhost:8500/test.cfm

Which will show:
Hello World!
```
Run this to see dump of server scope within container: navigate to `http://localhost:8500/dumpserver.cfm` in your web browser or run:
```
$ curl http://localhost:8500/dumpserver.cfm
```

Stop and remove the containers
```
$ docker-compose down
```