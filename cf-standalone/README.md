## Compose sample application
### ColdFusion standalone application

Project structure:
```
.
├── docker-compose.yaml
├── app
    └── test.cfm

```

[_docker-compose.yaml_](docker-compose.yaml)
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
Creating network "cf-standalone_default" with the default driver
Creating cf-standalone_coldfusion_1 ... done
Attaching to cf-standalone_coldfusion_1
coldfusion_1  | Updating webroot to /app
coldfusion_1  | Configuring virtual directories
coldfusion_1  | Updating password
...
coldfusion_1  | Starting ColdFusion
coldfusion_1  | Starting ColdFusion 2018 server ...
coldfusion_1  | The ColdFusion 2018 server is starting up and will be available shortly....
...
coldfusion_1  | Jul 28, 2020 03:51:12 AM Information [main] - ColdFusion started
coldfusion_1  | Jul 28, 2020 03:51:12 AM Information [main] - ColdFusion: application services are now available
coldfusion_1  | 07/28 03:51:12 INFO Macromedia Flex Build: 87315.134646
coldfusion_1  | Jul 28, 2020 03:51:22 AM Information [http-nio-8500-exec-2] - Initialize client.properties file

```

## Expected result

Listing containers must show two containers running and the port mapping as below:
```
$ docker ps
CONTAINER ID        IMAGE                                                    COMMAND                  CREATED              STATUS                        PORTS                                         NAMES
b8852a7be416        eaps-docker-coldfusion.bintray.io/cf/coldfusion:latest   "sh /opt/startup/sta…"   About a minute ago   Up About a minute (healthy)   8016/tcp, 45564/tcp, 0.0.0.0:8500->8500/tcp   cf-standalone_coldfusion_1
```

After the application starts, navigate to `http://localhost:8500` in your web browser or run:
```
$ curl localhost:8500
Hello World!
```

Stop and remove the containers
```
$ docker-compose down
```