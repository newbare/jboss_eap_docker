
# app JBoss EAP 6.4.5 Docker image
This project builds a docker container for running JBoss EAP 6.4.5.GA.

## Requirements:

#### Install [Docker](https://www.docker.io/gettingstarted/#1)

__Windows 10+ pro users__ : Prefer _Docker for Windows_ over ~~Docker Toolbox~~ 

__Mac Users__ : Prefer _Docker for Mac_ over ~~Docker Toolbox~~ 

__Windows 7 Users__ : Docker Toolbox may be your only choice, prefer using Windows 10 Pro machine

More at [https://nickjanetakis.com/blog/should-you-use-the-docker-toolbox-or-docker-for-mac-windows]

#### Ensure Resources and Dependencies are available to build image from `./Dockerfile`

_If you have access to [downloads/] as the Dockerfile ADD(s)_

1. [JBoss EAP 6.4.0 zip distribution](downloads/)
2. [JDK rpm](downloads/)
3. Folder `/jce-unlimited directory`, ADD(s) JCE unlimited policy files (local_policy.jar / US_export_policy.jar)
4. Folder `/trusted-root-ca directory`, ADD(s) your trusted root CA files (in .pem format)

If you do not have access to [downloads/]
1. Download `jboss-eap-6.4.0.zip` and `jdk-8u144-linux-x64.rpm`, place them a local folder
2. Set build-arg DOWNLOAD_LINK to source dependencies from an absolute local folder instead of [downloads/] 



## Usage (building and using image directly)


### Build image and tag it
    $ docker build . -t simars/redhat-jboss-eap

### Run Containers

#### Prepare jboss base folder (ex /Users/usernmae/jboss-eap-dev)

```

/Users/usernmae/jboss-eap-dev/jboass-eap-dev 
   |
   |__configuration__ [contains standalone-*.xml etc etc]
   |
   |__deployments__ [contains ear and wars to be deployed]

```

```
 look ./example/app.env for typical env required for JBOSS ex JAVA_OPTS=...
```

You can checkout `./jboess-eap-dev` and `./jboss-eap-ha` base folders as an example
Everything except app.ear file is checked in, just place the ear file in deployments folder 


#### Run a container named (app1) with the built image 
    docker run --name app1 -h app1 -d -p 8444:8443 -p 9991:9990 -it --rm --env-file=app.env --privileged -v $(pwd):/base:ro  jboss-eap
    
###### Notice `-v {$pwd}` is mounting the base folder you have prepared
###### Notice, `-p 8444:8443` we have which exposes <port-on-your-machine>:<internal-port-of-container>
###### Notice  `--env-file=app.env`, as it provides environment variables for container
###### Windows user's `${pwd}` may not work, use the absolute path of current working dir ex 
    -v C:/Users/<username>/<working-copy/jboss-eap-dev>:/base:ro


##### Working on running Container(s)

###### checkout logs of your container
    $ docker logs -f app1

###### bash into your container
    $ docker exec -it app1 bash
    app1$ ls /base; echo "gives you contents of the base folder mounted";
    app1$ tail -f /var/log/jboss/console.log

###### Stop the container
    $ docker stop app1

##### Since you started the container with `--rm` option, stop will remove the container also. Otherwise
    $ docker rm app1

