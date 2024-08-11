## Compose watch sample application

This example can be used to demonstrate use of the `docker compose watch` feature, which works similarly to using a volume (to mount, for example, the host app folder into the container app folder, as has been demonstrted in most examples in this repo), but instead it works like a one-way sync.

You can edit files in the host side of the synced pair of foldeers, and the changes will be detected and made available immediately within the running container (as would be true with a volume), but the sync is only one-way, whereas a default volume is bi-directional (changes in the container would be reflected in the host).

There are more valuable benefits to the compose watch feature (such as watching a file or folder to trigger a service rebuild rather than a folder sync), and later iterations of this example may expand on those.

### ColdFusion standalone application

Project structure:
```
.
├── compose.yaml
├── Dockerfile
├── app
    └── test.cfm
    └── dumpserver.cfm

```

[_compose.yaml_](compose.yaml)
```
services:
    # run with docker compose watch (rather than docker compose up)
    coldfusion:
        image: adobecoldfusion/coldfusion2021:latest
        # build directive runs dockerfile, and is needed in order for compose watch directives below to work
        build: .
        ports:
        - "8500:8500"
        environment:
            - acceptEULA=YES
            - password=123
        develop:
            # define the folder that should be watched/synced (one-way) from the host into the container
            watch:
                - action: sync
                  path: .\app
                  target: /app
```

## Deploy with docker-compose watch

Unlike nearly all other examples here, to leverage the "watch" feature of Docker Compose, this compose file should be started with `docker compose watch` rather `than docker compose up`.

Note also that the watch feature defaults to running containers in the background, so there's no need for the `-d` argument (as used with other `docker compose up` examples here).

```
$ docker-compose watch
[+] Building 2.0s (7/7) FINISHED                                                                         docker:default
 => [coldfusion internal] load build definition from Dockerfile                                                    0.2s
 => => transferring dockerfile: 96B                                                                                0.1s
 => [coldfusion internal] load .dockerignore                                                                       0.1s
 => => transferring context: 2B                                                                                    0.1s
 => [coldfusion internal] load metadata for docker.io/adobecoldfusion/coldfusion2021:latest                        0.0s
 => [coldfusion internal] load build context                                                                       0.2s
 => => transferring context: 93B                                                                                   0.1s
 => [coldfusion 1/2] FROM docker.io/adobecoldfusion/coldfusion2021:latest                                          0.1s
 => [coldfusion 2/2] COPY ./app /app                                                                               1.2s
 => [coldfusion] exporting to image                                                                                0.1s
 => => exporting layers                                                                                            0.1s
 => => writing image sha256:d037c397530bb85d5026ce3ae08b7832122490ec07a09544f5f284bf16713da5                       0.0s
 => => naming to docker.io/adobecoldfusion/coldfusion2021:latest                                                   0.0s
[+] Running 2/2
 ✔ Network cf-2021-compose-watch_default         Created                                                           0.3s
 ✔ Container cf-2021-compose-watch-coldfusion-1  Started                                                           0.5s
Watch configuration for service "coldfusion":
  - Action sync for path "C:\\github\\awesome-cf-compose\\cf-2021-compose-watch\\app"
...
```

## Expected result

Listing containers must show one container running and the port mapping as below (note that the version reported may differ for you, in using the "latest" tag):
```
$ docker ps
CONTAINER ID   IMAGE                                   COMMAND                  CREATED              STATUS
                    PORTS                                                   NAMES
dddfe0884890   adobecoldfusion/coldfusion2021:latest   "sh /opt/startup/sta…"   About a minute ago   Up About a minute (health: starting)   5005/tcp, 8120/tcp, 45564/tcp, 0.0.0.0:8500->8500/tcp   cf-2021-compose-watch-coldfusion-1

```

After the application starts, navigate to `http://localhost:8500` in your web browser to see available files in CF's default webroot (added to by the /app volume mapping)

Or run `http://localhost:8500/test.cfm` in your web browser to see the test page in the mapped /app folder, or run via curl:
```
$ curl http://localhost:8500/test.cfm

Which will show:
Hello World! at 25-Dec-2023 05:10:47
```
Run this to see a dump of the server.coldfusion struct within the container: navigate to `http://localhost:8500/dumpserver.cfm` in your web browser or run:
```
$ curl http://localhost:8500/dumpserver.cfm
```

Stop and remove the containers (to be clear, `docker compose down` still works, even though this was started with `docker compose watch`)
```
$ docker-compose down
```